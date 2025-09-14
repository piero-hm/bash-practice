#!/usr/bin/env bash
# snapinfo - genera un informe rápido del sistema y lo guarda con timestamp
set -euo pipefail

IFS=$'\n\t'

VERSION="0.1"
OUTDIR="${HOME}/.snapinfo"
SHORT=0
TOPN=5

timestamp() { date +%Y%m%d-%H%M%S; }
log() { echo "[snapinfo] $*"; }

usage() {
  cat <<EOF
snapinfo $VERSION
Genera un informe del sistema.

Opciones:
  --save DIR   Guardar informes en DIR (por defecto $OUTDIR)
  --short      Generar versión corta (menos detalle)
  --top N      Mostrar top N procesos por CPU (por defecto $TOPN)
  --help       Mostrar esta ayuda
EOF
}

while [[ ${1-} != "" ]]; do
  case "$1" in
  --save)
    OUTDIR="$2"
    shift 2
    ;;
  --short)
    SHORT=1
    shift
    ;;
  --top)
    TOPN="$2"
    shift 2
    ;;
  --help)
    usage
    exit 0
    ;;
  *)
    echo "Opción desconocida: $1"
    usage
    exit 1
    ;;
  esac
done

for cmd in uname lscpu df free date awk ps hostname; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Advertencia: comando $cmd no encontrado en el sistema."
  fi
done

TS=$(timestamp)
mkdir -p "$OUTDIR"
OUTFILE="$OUTDIR/snap-$TS.txt"

{
  echo "snapinfo - informe del sistema"
  echo "Fecha: $(date '+%F %T')"
  echo "Host: $(hostname) ($(whoami)@$(hostname -f 2>/dev/null || hostname))"
  echo "----------------------------------------"
  echo ""
  echo "1) Kernel / OS"
  uname -a 2>/dev/null || echo "uname no disponible"
  echo ""

  if [[ $SHORT -eq 0 ]]; then
    echo "2) CPU (lscpu)"
    lscpu 2>/dev/null || echo "lscpu no disponible"
    echo ""
  fi

  echo "3) Memoria"
  free -h 2>/dev/null || echo "free no disponible"
  echo ""

  echo "4) Uso de disco (df -h)"
  df -h --total 2>/dev/null || df -h 2>/dev/null || echo "df no disponible"
  echo ""

  if [[ $SHORT -eq 0 ]]; then
    echo "5) Montajes y puntos críticos (mount | grep -E '(/home|/|/var)')"
    mount | awk '/ on /{print}' | grep -E '(/home|/var|/)$' || mount
    echo ""
  fi

  echo "6) IPs (interfaces)"
  # intenta hostname -I, si no, ip addr
  if hostname -I >/dev/null 2>&1; then
    echo "IPs: $(hostname -I)"
  else
    ip -4 addr show 2>/dev/null || echo "ip no disponible"
  fi
  echo ""

  echo "7) Top $TOPN procesos por CPU"
  ps -eo pid,%cpu,%mem,comm --sort=-%cpu | head -n $((TOPN + 1)) 2>/dev/null || ps aux | sort -nrk 3 | head -n $((TOPN + 1))
  echo ""

  if [[ $SHORT -eq 0 ]]; then
    echo "8) Últimos logs (dmesg tail 20)"
    dmesg 2>/dev/null | tail -n 20 || echo "dmesg no disponible o requiere permisos"
    echo ""
    echo "9) Servicios de usuario (systemctl --user list-units --type=service --state=running) (si systemd)"
    if command -v systemctl >/dev/null 2>&1; then
      systemctl --user list-units --type=service --state=running 2>/dev/null || systemctl list-units --type=service --state=running 2>/dev/null
    else
      echo "systemctl no disponible"
    fi
    echo ""
  fi

  echo "10) Versiones (bash, python, git si existen)"
  command -v bash >/dev/null 2>&1 && bash --version | head -n1 || true
  command -v python3 >/dev/null 2>&1 && python3 --version || true
  command -v git >/dev/null 2>&1 && git --version || true
  echo ""
  echo "Fin del informe."
} >"$OUTFILE"

chmod 600 "$OUTFILE"
log "Informe guardado en: $OUTFILE"
echo
echo "Vista previa (primeras 20 líneas):"
head -n 20 "$OUTFILE"
