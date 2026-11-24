import std/[osproc, strutils, os]

const
  nimdeply_Ver = "0.2.0"
  exeName = "dclockGui2.exe"
  targetDir = "."
  mingwBin = "C:/msys64/mingw64/bin"
  # ### INIZIO MODIFICA 1: configurazione windeployqt ###
  windeployqt = mingwBin / "windeployqt.exe"
  # opzioni: --no-translations evita le cartelle translations (togli se ti servono)
  #          --compiler-runtime prova a copiare libgcc/libstdc++/libwinpthread
  windeployArgs = "--no-translations --compiler-runtime"
  # ### FINE MODIFICA 1 ###

# ### INIZIO MODIFICA 2: deployDlls ora riceve il file da analizzare ###
# vecchia firma:
# proc deployDlls() =
#   # esegui ldd e cattura l'output
#   let (output, _) = execCmdEx("ldd " & exeName)
proc deployDlls(fileName: string) =
  # esegui ldd e cattura l'output
  let (output, _) = execCmdEx("ldd \"" & fileName & "\"")
# ### FINE MODIFICA 2 ###

  for line in output.splitLines():
    # cerca solo le righe con mingw64
    if "mingw64/bin" notin line: continue

    # estrai il nome della dll (primo campo)
    let parts = line.strip().split("=>")
    if parts.len < 2: continue
    let dllName = parts[0].strip()

    # controlla se esiste già nella cartella target
    if fileExists(targetDir / dllName):
      echo "già presente: " & dllName
      continue

    # copia da mingw64
    let src = mingwBin / dllName
    if fileExists(src):
      copyFile(src, targetDir / dllName)
      echo "copiato: " & dllName
    else:
      echo "NON TROVATO: " & dllName

# ### INIZIO MODIFICA 3: lancia windeployqt prima di ldd ###
proc deployQt() =
  if not fileExists(windeployqt):
    quit("windeployqt non trovato: " & windeployqt, 1)
  echo "=== windeployqt ==="
  let (output, code) = execCmdEx("\"" & windeployqt & "\" " & windeployArgs &
                                 " \"" & targetDir / exeName & "\"")
  echo output
  if code != 0:
    quit("windeployqt fallito (codice " & $code & ")", 1)
# ### FINE MODIFICA 3 ###

# ### INIZIO MODIFICA 4: sequenza di deploy ###
# vecchia chiamata:
# deployDlls()
deployQt()                         # 1) Qt: dll, plugin, ecc.

echo "=== dipendenze exe ==="
deployDlls(exeName)                # 2) dipendenze mingw dell'exe (come prima)

echo "=== dipendenze plugin ==="     # 3) dipendenze mingw dei plugin Qt
for f in walkDirRec(targetDir):
  if f.endsWith(".dll") and parentDir(f) != targetDir.absolutePath and
     parentDir(f) != targetDir:
    deployDlls(f)
# ### FINE MODIFICA 4 ###
