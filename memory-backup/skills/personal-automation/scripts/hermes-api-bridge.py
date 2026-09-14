#!/usr/bin/env python3
"""
hermes-api-bridge.py
Bridge HTTP para chamadas a APIs com cache, retry e formatção de saída.
"""

import argparse
import hashlib
import json
import os
import sys
import time
from datetime import datetime
from pathlib import Path
from urllib.parse import urlencode

# Dependências padrão do Python (sem install necessário)
from urllib.request import Request, urlopen
from urllib.error import HTTPError, URLError
from http.cookiejar import DefaultCookieProcessor
import ssl

# --- Configuração ---
LOG_FILE = os.environ.get("HERMES_LOG_DIR", "/tmp") + "/hermes-automation.log"
CACHE_DIR = os.path.expanduser("~/.cache/hermes-api-bridge")
DEFAULT_CACHE_TTL = int(os.environ.get("HERMES_API_CACHE_TTL", "3600"))
DEFAULT_RETRIES = 3
DEFAULT_RETRY_DELAY = 1.0

# --- Logging ---
def log(msg: str) -> None:
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    line = f"[{timestamp}] [api-bridge] {msg}"
    try:
        with open(LOG_FILE, "a") as f:
            f.write(line + "\n")
    except OSError:
        pass


def warn(msg: str) -> None:
    log(f"WARN: {msg}")
    print(f"⚠️  WARN: {msg}", file=sys.stderr)


def err(msg: str) -> None:
    log(f"ERROR: {msg}")
    print(f"❌ ERROR: {msg}", file=sys.stderr)


# --- Cache ---
def get_cache_key(url: str, method: str, headers: dict, data: str | None) -> str:
    """Gera chave de cache baseada na requisição."""
    content = f"{method}:{url}:{json.dumps(sorted(headers.items()))}:{data or ''}"
    return hashlib.sha256(content.encode()).hexdigest()


def get_cached(key: str, ttl: int) -> dict | None:
    """Recupera item do cache se válido."""
    cache_file = Path(CACHE_DIR) / f"{key}.json"
    if not cache_file.exists():
        return None

    try:
        with open(cache_file) as f:
            cached = json.load(f)

        age = time.time() - cached.get("timestamp", 0)
        if age > ttl:
            cache_file.unlink(missing_ok=True)
            return None

        log(f"Cache HIT: {key[:16]}... (age={age:.0f}s)")
        return cached.get("response")
    except (json.JSONDecodeError, OSError):
        cache_file.unlink(missing_ok=True)
        return None


def set_cached(key: str, response: dict) -> None:
    """Armazena resposta no cache."""
    Path(CACHE_DIR).mkdir(parents=True, exist_ok=True)
    cache_file = Path(CACHE_DIR) / f"{key}.json"

    try:
        with open(cache_file, "w") as f:
            json.dump({"timestamp": time.time(), "response": response}, f)
        log(f"Cache SET: {key[:16]}...")
    except OSError as e:
        warn(f"Falha ao escrever cache: {e}")


# --- HTTP ---
def make_request(
    url: str,
    method: str = "GET",
    headers: dict | None = None,
    data: str | None = None,
    retries: int = DEFAULT_RETRIES,
    retry_delay: float = DEFAULT_RETRY_DELAY,
    timeout: int = 30,
) -> dict:
    """Executa requisição HTTP com retry."""
    headers = headers or {}
    headers.setdefault("User-Agent", "Hermes-API-Bridge/1.0")
    headers.setdefault("Accept", "application/json")

    if data and "Content-Type" not in headers:
        headers["Content-Type"] = "application/json"

    ssl_context = ssl.create_default_context()

    last_error = None
    for attempt in range(1, retries + 1):
        try:
            log(f"Request: {method} {url} (attempt {attempt}/{retries})")

            req = Request(url, data=data.encode() if data else None, headers=headers, method=method)
            handler = DefaultCookieProcessor()
            opener = urlopen(handler)

            response = opener(req, timeout=timeout, context=ssl_context)
            body = response.read().decode("utf-8")

            result = {
                "status": response.status,
                "headers": dict(response.headers),
                "body": body,
                "url": response.url,
                "attempt": attempt,
            }

            # Tentar parsear como JSON
            try:
                result["json"] = json.loads(body)
            except json.JSONDecodeError:
                pass

            log(f"Response: {response.status} ({len(body)} bytes, attempt {attempt})")
            return result

        except HTTPError as e:
            last_error = f"HTTP {e.code}: {e.reason}"
            warn(f"Tentativa {attempt}/{retries} falhou: {last_error}")

            # 4xx (exceto 429) não deve ser retry
            if 400 <= e.code < 500 and e.code != 429:
                return {
                    "status": e.code,
                    "error": last_error,
                    "body": e.read().decode("utf-8", errors="replace") if e.fp else "",
                    "attempt": attempt,
                }

        except URLError as e:
            last_error = f"URL Error: {e.reason}"
            warn(f"Tentativa {attempt}/{retries} falhou: {last_error}")

        except Exception as e:
            last_error = str(e)
            warn(f"Tentativa {attempt}/{retries} falhou: {last_error}")

        if attempt < retries:
            delay = retry_delay * (2 ** (attempt - 1))  # exponential backoff
            log(f"Aguardando {delay:.1f}s antes da próxima tentativa...")
            time.sleep(delay)

    return {"status": 0, "error": f"Todas as {retries} tentativas falharam: {last_error}", "attempt": retries}


# --- Formatação de Saída ---
def format_output(result: dict, fmt: str) -> str:
    """Formata resultado para saída."""
    if fmt == "json":
        return json.dumps(result, indent=2, ensure_ascii=False)

    elif fmt == "text":
        lines = []
        lines.append(f"Status: {result.get('status', 'N/A')}")
        lines.append(f"URL: {result.get('url', 'N/A')}")
        lines.append(f"Tentativas: {result.get('attempt', 'N/A')}")

        if "error" in result:
            lines.append(f"Erro: {result['error']}")
        elif "json" in result:
            lines.append(f"Body (JSON): {json.dumps(result['json'], indent=2, ensure_ascii=False)[:2000]}")
        elif "body" in result:
            lines.append(f"Body: {result['body'][:2000]}")

        return "\n".join(lines)

    elif fmt == "table":
        lines = ["┌─────────────┬─────────────────────────────┐"]
        lines.append(f"│ {'Status':<11} │ {str(result.get('status', 'N/A')):<27} │")
        lines.append(f"│ {'URL':<11} │ {str(result.get('url', 'N/A'))[:27]:<27} │")
        lines.append(f"│ {'Tentativas':<11} │ {str(result.get('attempt', 'N/A')):<27} │")

        if "error" in result:
            lines.append(f"│ {'Erro':<11} │ {str(result['error'])[:27]:<27} │")

        lines.append("└─────────────┴─────────────────────────────┘")
        return "\n".join(lines)

    return json.dumps(result, indent=2)


# --- CLI ---
def main():
    parser = argparse.ArgumentParser(
        description="Hermes API Bridge - Chamadas HTTP com cache e retry",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemplos:
  %(prog)s --url https://api.github.com/users/octocat
  %(prog)s --url https://httpbin.org/post --method POST --data '{"key":"value"}'
  %(prog)s --url https://api.example.com/data --cache-ttl 600 --retries 5
  %(prog)s --url https://api.example.com/data --header "Authorization: Bearer TOKEN"
        """,
    )

    parser.add_argument("--url", required=True, help="URL da API (obrigatório)")
    parser.add_argument("--method", default="GET", choices=["GET", "POST", "PUT", "DELETE", "PATCH"],
                        help="Método HTTP (default: GET)")
    parser.add_argument("--header", action="append", dest="headers", metavar="KEY:VALUE",
                        help="Header HTTP (repetível)")
    parser.add_argument("--data", help="Corpo da requisição (POST/PUT)")
    parser.add_argument("--cache-ttl", type=int, default=DEFAULT_CACHE_TTL,
                        help=f"TTL do cache em segundos (default: {DEFAULT_CACHE_TTL})")
    parser.add_argument("--no-cache", action="store_true", help="Desabilitar cache")
    parser.add_argument("--retries", type=int, default=DEFAULT_RETRIES,
                        help=f"Número de tentativas (default: {DEFAULT_RETRIES})")
    parser.add_argument("--retry-delay", type=float, default=DEFAULT_RETRY_DELAY,
                        help=f"Delay entre tentativas em segundos (default: {DEFAULT_RETRY_DELAY})")
    parser.add_argument("--timeout", type=int, default=30,
                        help="Timeout da requisição em segundos (default: 30)")
    parser.add_argument("--output", choices=["json", "text", "table"], default="json",
                        help="Formato de saída (default: json)")
    parser.add_argument("--verbose", action="store_true", help="Saída detalhada")

    args = parser.parse_args()

    # Parse headers
    headers = {}
    if args.headers:
        for h in args.headers:
            if ":" in h:
                key, value = h.split(":", 1)
                headers[key.strip()] = value.strip()

    # Verificar cache
    cache_key = None
    if not args.no_cache:
        cache_key = get_cache_key(args.url, args.method, headers, args.data)
        cached = get_cached(cache_key, args.cache_ttl)
        if cached:
            print(format_output(cached, args.output))
            sys.exit(0)

    # Executar requisição
    result = make_request(
        url=args.url,
        method=args.method,
        headers=headers,
        data=args.data,
        retries=args.retries,
        retry_delay=args.retry_delay,
        timeout=args.timeout,
    )

    # Salvar no cache (apenas respostas bem-sucedidas)
    if not args.no_cache and cache_key and result.get("status", 0) == 200:
        set_cached(cache_key, result)

    # Saída
    print(format_output(result, args.output))

    # Exit code
    status = result.get("status", 0)
    if 200 <= status < 300:
        sys.exit(0)
    else:
        sys.exit(1)


if __name__ == "__main__":
    main()
