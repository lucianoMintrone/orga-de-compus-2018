# Qsort

## Compilacion
Para compilar hacer `make`

Eso genera un ejecutable `qsort`


## Ejecucion

Para ejecutar el programa correr

```bash
./qsort (-n) -o <output_file> -i <input_file>
```

- _-o_ Es el archivo de salida donde se quiere guardar la lista ordenada, de ser el caracter _-_ este se imprimirá en el _stdout_ y
- _-i_ Es para indicar el archivo de entrada, a ordenar.
- _-h_ Se puede consultar la ayuda
- _-V_ La versión
- _-n_ Se le indica si quiere que se ordene alfabéticamente o numéricamente, por ejemplo los números _1, 2, 11_ están ordenados numéricamente pero no alfabéticamente. Donde su orden seria _1, 11, 2_.


## Tests
Para ejecutar los tests correr './test.sh'
