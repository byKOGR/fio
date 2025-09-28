#!/usr/bin/env bash
#
# 📊 fio_benchmark.sh - Uniwersalny skrypt benchmarku dysków oparty o FIO
# Author: YourName
# License: MIT
# Version: 1.0.0
#
# ✅ Funkcje:
#  - Automatyczne testy sekwencyjne i losowe (zapis/odczyt)
#  - Automatyczne raporty TXT + CSV z datą i nazwą hosta
#  - Tryb interaktywny lub z flagami CLI
#  - Tryb szybki (-q) do krótkich testów
#
# 📦 Użycie:
#  ./fio_benchmark.sh [-d <ścieżka>] [-q] [-f]
#
#  -d   katalog testowy (jeśli nie podany – zapyta)
#  -q   szybki tryb testów (30 s, mniejsze pliki)
#  -f   wymusza nadpisanie starych wyników
#

set -euo pipefail

# 🎨 Kolory
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"

# 📁 Parametry
TEST_DIR=""
QUICK_MODE=false
FORCE=false

# 📦 Parsowanie flag
while getopts ":d:qf" opt; do
  case $opt in
    d) TEST_DIR="$OPTARG" ;;
    q) QUICK_MODE=true ;;
    f) FORCE=true ;;
    *) echo -e "${RED}❌ Nieznana flaga.${NC}" && exit 1 ;;
  esac
done

# 📁 Pobierz katalog, jeśli nie podano
if [ -z "$TEST_DIR" ]; then
  read -rp "📁 Podaj katalog do testu: " TEST_DIR
fi

# 🧪 Walidacja katalogu
if [ ! -d "$TEST_DIR" ]; then
  echo -e "${RED}❌ Katalog '$TEST_DIR' nie istnieje.${NC}"
  exit 1
fi
if [ ! -w "$TEST_DIR" ]; then
  echo -e "${RED}❌ Brak uprawnień do zapisu w '$TEST_DIR'.${NC}"
  exit 1
fi

# 📁 Plik testowy
TEST_FILE="$TEST_DIR/fiotest"

# 📊 Ustawienia czasu i wielkości w zależności od trybu
if [ "$QUICK_MODE" = true ]; then
  RUNTIME=30
  SIZE_SEQ="1G"
  SIZE_RAND="256M"
else
  RUNTIME=120
  SIZE_SEQ="10G"
  SIZE_RAND="1G"
fi

# 🕐 Daty i nazwy raportów
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
HOST=$(hostname)
LOG_FILE="$PWD/fio_${HOST}_${DATE}.log"
SUMMARY_FILE="$PWD/fio_summary_${HOST}_${DATE}.txt"
CSV_FILE="$PWD/fio_results_${HOST}_${DATE}.csv"

if [ -f "$LOG_FILE" ] && [ "$FORCE" = false ]; then
  echo -e "${YELLOW}⚠️  Plik logu już istnieje. Użyj -f aby go nadpisać.${NC}"
  exit 1
fi

echo "=== 🚀 FIO Benchmark ==="
echo "📂 Katalog: $TEST_DIR"
echo "🖥️ Host: $HOST"
echo "🕐 Tryb: $([ "$QUICK_MODE" = true ] && echo 'SZYBKI' || echo 'PEŁNY')"
echo "📊 Wyniki: $SUMMARY_FILE"
echo ""

# 📊 Funkcja uruchamiająca test
run_test() {
  local name=$1
  local args=$2
  echo -e "${YELLOW}▶️  $name${NC}"
  fio --filename="$TEST_FILE" $args | tee -a "$LOG_FILE" > /dev/null
}

# 🧪 Testy
run_test "Sekwencyjny zapis (1M)" "--direct=1 --ioengine=libaio --iodepth=16 --runtime=$RUNTIME --numjobs=1 --time_based --group_reporting --name=seq-write --eta-newline=1 --size=$SIZE_SEQ --rw=write --bs=1M"
run_test "Sekwencyjny odczyt (1M)" "--direct=1 --ioengine=libaio --iodepth=16 --runtime=$RUNTIME --numjobs=1 --time_based --group_reporting --name=seq-read --eta-newline=1 --size=$SIZE_SEQ --rw=read --bs=1M"
run_test "Losowy zapis (4K)" "--direct=1 --ioengine=libaio --iodepth=32 --runtime=$RUNTIME --numjobs=16 --time_based --group_reporting --name=rand-write --eta-newline=1 --size=$SIZE_RAND --rw=randwrite --bs=4K"
run_test "Losowy odczyt (4K)" "--direct=1 --ioengine=libaio --iodepth=32 --runtime=$RUNTIME --numjobs=16 --time_based --group_reporting --name=rand-read --eta-newline=1 --size=$SIZE_RAND --rw=randread --bs=4K"

rm -f "$TEST_FILE"

# 📊 Tworzenie CSV i podsumowania
echo "Test,Typ,Blok,Rozmiar,Przepustowość (MB/s),IOPS,Opóźnienie (µs)" > "$CSV_FILE"

extract_result() {
  local test_name=$1
  local mode=$2
  local block=$3
  local size=$4
  local bw=$(grep -A2 "$test_name" "$LOG_FILE" | grep -E "$mode:" | sed -E 's/.*bw=([0-9\.]+)MB\/s.*/\1/' | head -n 1)
  local iops=$(grep -A5 "$test_name" "$LOG_FILE" | grep IOPS= | sed -E 's/.*IOPS=([0-9\.kM]+),.*/\1/' | head -n 1)
  local lat=$(grep -A10 "$test_name" "$LOG_FILE" | grep "lat (avg):" | sed -E 's/.*lat \(avg\): *([0-9\.]+).*/\1/' | head -n 1)
  echo "$test_name,$mode,$block,$size,${bw:-0},${iops:-0},${lat:--}" >> "$CSV_FILE"
}

extract_result "seq-write" "WRITE" "1M" "$SIZE_SEQ"
extract_result "seq-read" "READ" "1M" "$SIZE_SEQ"
extract_result "rand-write" "WRITE" "4K" "$SIZE_RAND"
extract_result "rand-read" "READ" "4K" "$SIZE_RAND"

# 📊 Podsumowanie tekstowe
cat <<EOF > "$SUMMARY_FILE"
=== 📊 FIO Benchmark Raport ===
📅 Data: $DATE
🖥️ Host: $HOST
📂 Katalog: $TEST_DIR
⏱️ Tryb: $([ "$QUICK_MODE" = true ] && echo 'Szybki (30s)' || echo 'Pełny (120s)')
───────────────────────────────
$(column -t -s, "$CSV_FILE")
───────────────────────────────
📁 Pełny log: $LOG_FILE
📈 CSV:       $CSV_FILE
EOF

echo -e "${GREEN}✅ Benchmark zakończony pomyślnie!${NC}"
echo -e "📊 Raport: ${SUMMARY_FILE}"
echo -e "📈 CSV:    ${CSV_FILE}"
