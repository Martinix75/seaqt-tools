#[
Smart connect macro che deduce automaticamente il tipo del widget
by MArtinix75 2025
version 0.6.2 piu argomenti generici
]#
import std/[macros, tables, strutils, typeinfo]

# Versione ottimizzata della procedura - più chiara e efficiente
proc ecexioniXX(widgetTypeName: string): bool = 
  # Widget che NON usano il wrapper del tipo slot (es: QSliderValueChangedSlot)
  # ma chiamano direttamente il segnale con la procedura
  const ecezioniX = ["Slider", "Widget", "Button"] # Costante per performance
  result = widgetTypeName in ecezioniX

# Funzione per costruire automaticamente il nome dello slot
proc buildSlotName(widgetTypeName: string, signalName: string): NimNode =
  # Rimuove "on" dall'inizio del segnale
  let cleanSignal = if signalName.startsWith("on"): signalName[2..^1] else: signalName
  # Costruisce: WidgetType + Signal + "Slot"
  let slotName = "Q" & widgetTypeName & cleanSignal & "Slot"
  result = ident(slotName)


# Mappa dei segnali speciali e i loro tipi di parametro
proc getSignalParameterTypes(): Table[string, NimNode] =
  result = {
    "onTextChanged": nnkBracketExpr.newTree(ident"openArray", ident"char"),
    "onStateChanged": ident"cint",
    "onValueChanged": ident"cint",
    "onCurrentTextChanged": nnkBracketExpr.newTree(ident"openArray", ident"char"),
    "onCurrentIndexChanged": ident"cint"
    # Aggiungi qui altri segnali con i loro tipi
  }.toTable

proc extractType(at: auto): string =
  echo "Debug - Widget type raw: ", at.treeRepr
  let typeRepr = $at.treeRepr
  
  # Trova il pattern "Q..." usando string operations invece di regex
  # Più sicuro per il contesto delle macro
  let startPos = typeRepr.find("\"Q")
  if startPos >= 0:
    let endPos = typeRepr.find("\"", startPos + 1)
    if endPos > startPos:
      let fullType = typeRepr[startPos+2..endPos-1] # Rimuove "Q e la virgoletta finale
      
      if fullType.startsWith("Abstract"):
        # Caso QAbstractButton -> Button
        result = fullType[8..^1] # Rimuove "Abstract"
        echo "Debug - Tipo estratto (QAbstract): ", result
      else:
        # Caso normale QLineEdit -> LineEdit  
        result = fullType
        echo "Debug - Tipo estratto (Q): ", result
    else:
      # Fallback se non trova la virgoletta di chiusura
      echo "Warning - Virgoletta di chiusura non trovata, uso metodo originale"
      let parts = typeRepr.split(" ")
      if parts.len > 5:
        if parts[5].startsWith("\"QAbstract"):
          result = parts[5][10..^3]
        else:
          result = parts[5][2..^3]
      else:
        result = "Unknown"
  else:
    # Fallback al metodo originale se non trova "Q
    echo "Warning - Pattern Q non trovato, uso metodo originale"
    let parts = typeRepr.split(" ")
    if parts.len > 5:
      if parts[5].startsWith("\"QAbstract"):
        result = parts[5][10..^3]
      else:
        result = parts[5][2..^3]
    else:
      result = "Unknown"
      echo "Error - Non riesco a estrarre il tipo del widget"
  
# Versione intelligente senza argomenti aggiuntivi  
macro connect*(widgetCall: untyped; widgetSignal: untyped; callFunction: untyped) =
  let signalParameterTypes = getSignalParameterTypes()
  let signalStr = $widgetSignal
  
  # Prova a ottenere il tipo del widget
  let widgetType = widgetCall.getType()
  let widgetTypeName = extractType(widgetType)
  
  # Controlla se è un segnale speciale
  if signalStr in signalParameterTypes and ecexioniXX(widgetTypeName) == false:
    # Widget normale - usa il wrapper del tipo slot
    echo "Debug - Widget type name: ", widgetTypeName
    
    let paramType = signalParameterTypes[signalStr]
    let slotType = buildSlotName(widgetTypeName, signalStr)
    
    echo "Debug - Generated slot type: ", $slotType
    
    # Genera il codice per segnali speciali (con parametri)
    result = quote do:
      `widgetCall`.`widgetSignal`(`slotType`(proc(qtArg: `paramType`) {.closure.} = `callFunction`()))
      
  elif signalStr in signalParameterTypes and ecexioniXX(widgetTypeName) == true:
    # Widget con eccezione - NON usa il wrapper del tipo slot
    echo "Debug - Widget type name (eccezione): ", widgetTypeName
    
    let paramType = signalParameterTypes[signalStr]
    
    echo "Debug - Usando connessione diretta (senza slot type wrapper)"
    
    # Genera il codice per segnali speciali (con parametri) ma senza wrapper
    result = quote do:
      `widgetCall`.`widgetSignal`((proc(qtArg: `paramType`) {.closure.} = `callFunction`()))
    
  else:
    # Genera il codice per segnali classici (senza parametri)  
    result = quote do:
      `widgetCall`.`widgetSignal`(proc() {.closure.} = `callFunction`())

#-----------------------------------------------------------------------------------------------------------
# Versione intelligente con argomento aggiuntivo
macro connect*[T](widgetCall: untyped; widgetSignal: untyped; callFunction: untyped; functionArg: T) =
  let signalParameterTypes = getSignalParameterTypes()
  let signalStr = $widgetSignal
  
  # Prova a ottenere il tipo del widget
  let widgetType = widgetCall.getType()
  let widgetTypeName = extractType(widgetType)
  
  # Controlla se è un segnale speciale
  if signalStr in signalParameterTypes and ecexioniXX(widgetTypeName) == false:
    # Widget normale - usa il wrapper del tipo slot
    echo "Debug - Widget type name: ", widgetTypeName
    
    let paramType = signalParameterTypes[signalStr]
    let slotType = buildSlotName(widgetTypeName, signalStr)
    
    echo "Debug - Generated slot type: ", $slotType
    
    # Genera il codice per segnali speciali (con parametri)
    result = quote do:
      `widgetCall`.`widgetSignal`(`slotType`(proc(qtArg: `paramType`) {.closure.} = `callFunction`(`functionArg`)))
      
  elif signalStr in signalParameterTypes and ecexioniXX(widgetTypeName) == true:
    # Widget con eccezione - NON usa il wrapper del tipo slot
    echo "Debug - Widget type name (eccezione): ", widgetTypeName
    
    let paramType = signalParameterTypes[signalStr]
    
    echo "Debug - Usando connessione diretta (senza slot type wrapper)"
    
    # Genera il codice per segnali speciali (con parametri) ma senza wrapper
    result = quote do:
      `widgetCall`.`widgetSignal`((proc(qtArg: `paramType`) {.closure.} = `callFunction`(`functionArg`)))
    
  else:
    # Genera il codice per segnali classici (senza parametri)  
    result = quote do:
      `widgetCall`.`widgetSignal`(proc() {.closure.} = `callFunction`(`functionArg`))
#-----------------------------------------------------------------------------------------------------------
# Versione intelligente con piu argomento aggiuntivo
macro connect*[T,R](widgetCall: untyped; widgetSignal: untyped; callFunction: untyped; functionArg: T; extraArg: R) =
  let signalParameterTypes = getSignalParameterTypes()
  let signalStr = $widgetSignal

  # Prova a ottenere il tipo del widget
  let widgetType = widgetCall.getType()
  let widgetTypeName = extractType(widgetType)

  # Controlla se è un segnale speciale
  if signalStr in signalParameterTypes and ecexioniXX(widgetTypeName) == false:
    # Widget normale - usa il wrapper del tipo slot
    echo "Debug - Widget type name: ", widgetTypeName

    let paramType = signalParameterTypes[signalStr]
    let slotType = buildSlotName(widgetTypeName, signalStr)

    echo "Debug - Generated slot type: ", $slotType

    # Genera il codice per segnali speciali (con parametri)
    result = quote do:
      `widgetCall`.`widgetSignal`(`slotType`(proc(qtArg: `paramType`) {.closure.} = `callFunction`(`functionArg`, `extraArg`)))

  elif signalStr in signalParameterTypes and ecexioniXX(widgetTypeName) == true:
    # Widget con eccezione - NON usa il wrapper del tipo slot
    echo "Debug - Widget type name (eccezione): ", widgetTypeName

    let paramType = signalParameterTypes[signalStr]

    echo "Debug - Usando connessione diretta (senza slot type wrapper)"

    # Genera il codice per segnali speciali (con parametri) ma senza wrapper
    result = quote do:
      `widgetCall`.`widgetSignal`((proc(qtArg: `paramType`) {.closure.} = `callFunction`(`functionArg`, `extraArg`)))

  else:
    # Genera il codice per segnali classici (senza parametri)
    result = quote do:
      `widgetCall`.`widgetSignal`(proc() {.closure.} = `callFunction`(`functionArg`, `extraArg`))
