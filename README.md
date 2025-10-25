🧪 FIO Disk Benchmark v1.1

**Uniwersalny skrypt do testowania wydajności dysków** (lokalnych, sieciowych, SSD, NVMe, HDD) z użyciem `fio`.  
Automatycznie generuje raport tekstowy i CSV, obsługuje tryb szybki, a także samodzielnie wykrywa problemy z I/O.

---

## 🚀 Funkcje

- ✅ Testy sekwencyjne (1M) i losowe (4K) — zapis i odczyt  
- ✅ Automatyczne raporty `.txt` i `.csv` z nazwą hosta i datą  
- ✅ Tryb szybki (`-q`) do krótkich testów diagnostycznych  
- ✅ Automatyczny **fallback**: jeśli `libaio` lub `--direct=1` nie działa, skrypt przełącza się na `sync`  
- ✅ Limit czasu (`timeout`) zabezpieczający przed zawieszeniem  
- ✅ Czytelny, kolorowy output w terminalu  
- ✅ Bezpieczny dla systemów plików NFS, ZFS, CIFS, Ceph, itp.

---

## 🧰 Wymagania

System Linux z zainstalowanym `fio`:

```bash
sudo apt install fio -y
````

---

## ⚙️ Użycie

Nadaj uprawnienia do wykonania:

```bash
chmod +x fio_benchmark.sh
```

Uruchomienie interaktywne (skrypt zapyta o katalog):

```bash
./fio_benchmark.sh
```

Lub z parametrami CLI:

```bash
./fio_benchmark.sh -d /mnt/dysk_testowy
```

---

## 🏁 Flagi CLI

| Flaga          | Opis                                                                |
| -------------- | ------------------------------------------------------------------- |
| `-d <ścieżka>` | Katalog testowy, w którym zostanie utworzony plik testowy `fiotest` |
| `-q`           | Tryb szybki (30s, mniejsze pliki – idealny do wielu maszyn)         |
| `-f`           | Wymusza nadpisanie istniejących logów                               |
| *(brak)*       | Skrypt poprosi o katalog interaktywnie                              |

---

## 🧪 Tryby testów

| Test               | Blok | Typ       | Domyślny rozmiar  | Opis                                 |
| ------------------ | ---- | --------- | ----------------- | ------------------------------------ |
| Sekwencyjny zapis  | 1M   | write     | 10G / 1G (quick)  | Ciągły zapis dużych bloków           |
| Sekwencyjny odczyt | 1M   | read      | 10G / 1G (quick)  | Ciągły odczyt dużych bloków          |
| Losowy zapis       | 4K   | randwrite | 1G / 256M (quick) | Symulacja IOPS                       |
| Losowy odczyt      | 4K   | randread  | 1G / 256M (quick) | Symulacja IOPS przy losowym dostępie |

---

## 📄 Wyniki

Po zakończeniu testów generowane są 3 pliki w bieżącym katalogu:

| Plik                        | Zawartość                           |
| --------------------------- | ----------------------------------- |
| `fio_summary_HOST_DATE.txt` | Podsumowanie w formie tekstowej     |
| `fio_results_HOST_DATE.csv` | Dane do Excela / analizy            |
| `fio_HOST_DATE.log`         | Pełny log `fio` z wynikami surowymi |

### 📊 Przykład CSV

```csv
Test,Typ,Blok,Rozmiar,Przepustowość (MB/s),IOPS,Opóźnienie (µs)
seq-write,WRITE,1M,10G,1120,1100,340
seq-read,READ,1M,10G,1180,1150,310
rand-write,WRITE,4K,1G,85,21800,420
rand-read,READ,4K,1G,92,23400,390
```

---

## 📘 Przykłady użycia

### 🔹 Pełny test dysku lokalnego

```bash
./fio_benchmark.sh -d /mnt/nvme
```

### 🔹 Szybki test (30 sekund, mniejsze pliki)

```bash
./fio_benchmark.sh -d /mnt/ssd -q
```

### 🔹 Test z wymuszeniem nadpisania starych wyników

```bash
./fio_benchmark.sh -d /mnt/hdd -f
```

---

## 🧩 Przykładowy wynik (terminal)

```
=== 🚀 FIO Benchmark ===
📂 Katalog: /mnt/data
🖥️ Host: test-node-01
🕐 Tryb: Pełny
📊 Wyniki: fio_summary_test-node-01_2025-10-25_13-00-01.txt

▶️  Sekwencyjny zapis (1M)
▶️  Sekwencyjny odczyt (1M)
▶️  Losowy zapis (4K)
▶️  Losowy odczyt (4K)

✅ Benchmark zakończony pomyślnie!
📊 Raport: fio_summary_test-node-01_2025-10-25_13-00-01.txt
📈 CSV:    fio_results_test-node-01_2025-10-25_13-00-01.csv
```

---

## ⚠️ Uwagi

* Testy **mogą potrwać** — szczególnie sekwencyjne zapisy przy dużych plikach (10G).
* Jeśli system plików nie obsługuje `O_DIRECT` lub `libaio`, skrypt automatycznie przełączy się na `sync`.
* Każdy test ma limit czasu (`timeout 300s`) — skrypt nie powinien się nigdy zawiesić.
* Po każdym teście plik tymczasowy jest automatycznie usuwany.

---

## 📜 Licencja

MIT License © 2025 — możesz używać, modyfikować i rozpowszechniać dowolnie.
Autor: *[Twoje imię / organizacja]*

---

## 💡 Wskazówki

* Skrypt możesz łatwo uruchamiać z GitHuba:

  ```bash
  curl -sSL https://raw.githubusercontent.com/<user>/fio-benchmark/main/fio_benchmark.sh | bash
  ```
* Jeśli testujesz wiele maszyn, CSV z nazwą hosta i datą pozwoli Ci łatwo zebrać wyniki.

```

---

### ✅ Co możesz teraz zrobić

- Wystarczy, że w swoim repo (`fio-benchmark`) nadpiszesz plik `README.md` powyższą treścią.  
- GitHub sam ładnie wyrenderuje sekcje, tabele i kod.  
- Jeśli chcesz, mogę dodać sekcję **„How to compare results across servers”** z prostym skryptem do łączenia CSV — chcesz, żebym to dopisał?
```
