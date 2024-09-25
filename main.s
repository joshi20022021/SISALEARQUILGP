//se define las variables globales para el programa
.global _start
.global convertirAsciiAEntero
.global convertirEnteroAAscii
.global iniciarCalculadora

//texto y cadenas
.data

saltoLinea:
    .asciz "\n"
lenSaltoLinea = . - saltoLinea

cabecera:
    .asciz "Universidad de San Carlos de Guatemala\n"
    .asciz "Facultad de Ingeniería\n"
    .asciz "Escuela de Ciencias y Sistemas\n"
    .asciz "Arquitectura de Computadores y Ensambladores 1\n"
    .asciz "Sección A\n"
    .asciz "Nombre: Edgar Josias Can Ajquejay\n"
    .asciz "Carnet: 202112012\n"
    .asciz "Presione Enter para continuar...\n"
lenCabecera = . - cabecera

menuPrincipal:
    .asciz "-------------------------------\n"
    .asciz "||       Menú Principal      ||\n"
    .asciz "||1. Suma                    ||\n"
    .asciz "||2. Resta                   ||\n"
    .asciz "||3. Multiplicación          ||\n"
    .asciz "||4. División                ||\n"
    .asciz "||5. Cálculo Con Memoria     ||\n"
    .asciz "||6. Salir                   ||\n"
    .asciz "||>> Ingrese Una Opción:     ||\n"
    .asciz "-------------------------------\n"
lenMenuPrincipal = . - menuPrincipal

entradaOperacion:
    .asciz ">> Ingrese La Operación: "
lenEntradaOperacion = . - entradaOperacion

mensajeConfirmarSalida:
    .asciz "¿Desea salir de la calculadora? (s/n): "
lenMensajeConfirmarSalida = . - mensajeConfirmarSalida

mensajeDespedida:
    .asciz "Gracias por usar la calculadora. ¡Hasta luego!\n"
lenMensajeDespedida = . - mensajeDespedida

errorDivisionCero:
    .asciz "Error: División Por Cero\n"
lenErrorDivisionCero = . - errorDivisionCero

mensajeOpcionInvalida:
    .asciz "Opción inválida. Por favor, intente de nuevo.\n"
lenMensajeOpcionInvalida = . - mensajeOpcionInvalida

//variables no inicializadas tamaño en bytes
.bss
opcionElegida:
    .space 5

bufferOperando:
    .zero 10
bufferResultado:
    .zero 10
bufferAuxiliar:
    .zero 10
primerOperando:
    .zero 8
segundoOperando:
    .zero 8
respuestaSalida:
    .zero 2

//ejecucion de las operaciones y metodos
.text

_start:
    B iniciarCalculadora

//impresion en salida estandar
.macro imprimir mensaje, longitud
    MOV x0, 1
    LDR x1, =\mensaje
    MOV x2, \longitud
    MOV x8, 64
    SVC 0
.endm

//leer entrada del usuario
.macro leerEntrada buffer, longitud
    MOV x0, 0
    LDR x1, =\buffer
    MOV x2, \longitud
    MOV x8, 63
    SVC 0
.endm

//convertir cadena a entero
convertirAsciiAEntero:
    SUB x5, x5, 1

//contar digitos
contarDigitos:
    LDRB w1, [x0], 1
    CBZ w1, convertirNumero
    CMP w1, 10
    BEQ convertirNumero
    B contarDigitos

//apuntador para conversion
convertirNumero:
    SUB x0, x0, 2
    MOV w4, 1
    MOV x7, 0

//convertir caracteres a entero
convertirCaracteres:
    LDRB w1, [x0], -1
    CMP w1, 45
    BEQ manejarNegativo

    SUB w1, w1, 48
    MUL w1, w1, w4
    ADD w7, w7, w1

    MOV w6, 10
    MUL w4, w4, w6

    CMP x0, x5
    BNE convertirCaracteres
    B finConversion

//si es negativo se invierte el resultado de + a -
manejarNegativo:
    NEG w7, w7

finConversion:
    STR w7, [x8]
    RET

//convertir entero a cadena
convertirEnteroAAscii:
    MOV x10, 0
    MOV x12, 0
    MOV w2, 10000
    CMP w0, 0
    BGT convertirAscii

    CMP w0, 0
    BEQ manejarCero
    B manejarNegativoEntero

//manejo del cero como resultado
manejarCero:
    ADD x10, x10, 1
    MOV w5, 48
    STRB w5, [x1], 1
    B finConversionAscii

//manejo de numeros negativos
manejarNegativoEntero:
    MOV x12, 1
    MOV w5, 45
    STRB w5, [x1], 1
    NEG w0, w0

//conversion de entero a ascii
convertirAscii:
    UDIV w3, w0, w2
    CBZ w3, reducirBase

    CMP w2, 1
    BLE manejarUnidades

    ADD w5, w3, 48
    STRB w5, [x1], 1
    ADD x10, x10, 1

    MUL w3, w3, w2
    SUB w0, w0, w3

reducirBase:
    MOV w6, 10
    UDIV w2, w2, w6

    CMP w2, 1
    BLE manejarUnidades

    CBNZ w10, agregarCero
    B convertirAscii

agregarCero:
    CBNZ w3, convertirAscii
    ADD x10, x10, 1
    MOV w5, 48
    STRB w5, [x1], 1
    B convertirAscii

manejarUnidades:
    CMP w2, 1
    BGT convertirAscii
    ADD x10, x10, 1
    MOV w5, w0
    ADD w5, w5, 48
    STRB w5, [x1], 1

finConversionAscii:
    ADD x10, x10, x12
    imprimir bufferResultado, x10
    RET

//inicio de la calculadora
iniciarCalculadora:
    imprimir cabecera, lenCabecera
    leerEntrada opcionElegida, 1

// verifica la opcion elegida por el usuario y ejecuta la operacion
//si la opcion es 6 realiza la confirmacion de salida
//caso contrario lee los operandos y ejecuta la operacion
buclePrincipal:
    imprimir menuPrincipal, lenMenuPrincipal
    leerEntrada opcionElegida, 5

    LDR x3, =opcionElegida
    LDRB w3, [x3]
    CMP w3, 54
    BEQ confirmarSalida

    imprimir entradaOperacion, lenEntradaOperacion
    leerEntrada bufferOperando, 10

    LDR x7, =bufferOperando

//verifica si los operandos vienen por separado o vienen por comas
validarEntrada:
    LDRB w8, [x7], 1
    CBZ w8, tipoEntrada1

    CMP w8, 44
    BEQ tipoEntrada3

    B validarEntrada

//realiza la conversion de ASCII a entero y ejecuta la operacion
//que se eligio
tipoEntrada1:
    LDR x0, =bufferOperando
    LDR x5, =bufferOperando
    LDR x8, =primerOperando
    BL convertirAsciiAEntero

    imprimir entradaOperacion, lenEntradaOperacion
    leerEntrada bufferOperando, 10

    LDR x0, =bufferOperando
    LDR x5, =bufferOperando
    LDR x8, =segundoOperando
    BL convertirAsciiAEntero

    B ejecutarOperacion

//verifica si los operandos vienen por comas, separa los operandos
//realiza la conversion de ASCII a entero y ejecuta la operacion
tipoEntrada3:
    MOV w8, 0
    STRB w8, [x7, -1]!
    ADD x7, x7, 1

    LDR x9, =bufferAuxiliar
    MOV x10, 0
copiarValor:
    LDRB w8, [x7]
    CMP w8, 10
    BEQ finCopiar

    STRB w8, [x9], 1
    STRB w8, [x7], 1
    B copiarValor

finCopiar: 
    MOV w8, 0
    STRB w8, [x9], 1

    LDR x0, =bufferOperando
    LDR x5, =bufferOperando
    LDR x8, =primerOperando
    BL convertirAsciiAEntero

    LDR x0, =bufferAuxiliar
    LDR x5, =bufferAuxiliar
    LDR x8, =segundoOperando
    BL convertirAsciiAEntero

//obtiene los valores de los operandos y la operacion a realizar
//ejecuta la operacion y muestra el resultado
//caso contrario si algo sale mal muestra un mensaje de error
ejecutarOperacion:
    MOV x2, 0
    MOV x3, 0

    LDR x0, =primerOperando
    LDR x1, =segundoOperando

    LDR w2, [x0]
    LDR w3, [x1]

    MOV x8, 0
    LDR x7, =opcionElegida
    LDRB w8, [x7]

    CMP w8, 49
    BEQ suma

    CMP w8, 50
    BEQ resta

    CMP w8, 51
    BEQ multiplicacion

    CMP w8, 52
    BEQ division

    imprimir mensajeOpcionInvalida, lenMensajeOpcionInvalida
    B buclePrincipal

//operacion suma
suma:
    ADD w3, w2, w3
    B mostrarResultado

//operacion resta
resta:
    SUB w3, w2, w3
    B mostrarResultado

//operacion multiplicacion
multiplicacion:
    SMULL x3, w2, w3
    B mostrarResultado

//operacion division
division:
    CMP w3, 0
    BEQ errorDivisionCero
    SDIV w3, w2, w3
    B mostrarResultado

//maneja la division por cero
errorDivisionCero:
    imprimir errorDivisionCero, lenErrorDivisionCero
    leerEntrada opcionElegida, 1
    B buclePrincipal

//muestra el resultado de la operacion
mostrarResultado:
    MOV x0, 0
    MOV w0, w3
    LDR x1, =bufferResultado

    BL convertirEnteroAAscii
    imprimir saltoLinea, lenSaltoLinea
    leerEntrada opcionElegida, 1
    B buclePrincipal

//realiza la confirmacion de salida si responde si, sale del programa
//caso contrario regresa al menu principal
confirmarSalida:
    imprimir mensajeConfirmarSalida, lenMensajeConfirmarSalida
    leerEntrada respuestaSalida, 2

    LDR x3, =respuestaSalida
    LDRB w3, [x3]

    CMP w3, 115
    BEQ despedirse

    CMP w3, 83
    BEQ despedirse

    B buclePrincipal

//mensaje de despedida y finaliza el programa
despedirse:
    imprimir mensajeDespedida, lenMensajeDespedida
    B finalizarPrograma

//finaliza el programa
finalizarPrograma:
    MOV x0, 0
    MOV x8, 93
    SVC 0
