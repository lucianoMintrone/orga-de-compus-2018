#include <stdbool.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <getopt.h>

extern void qsort(char** izq, char** der, int num);

void show_version() {
	printf("1.0.0\n");
}

void show_help() {
	printf("Usage:\n"
		"   qsort -h\n"
		"   qsort -V\n"
		"   qsort [options] archivo\n"
		"Options:\n"  
	 	"   -h, --help Imprime ayuda.\n"
		"   -V, --version Version del programa.\n"
		"   -o, --output Archivo de salida.\n"
		"   -n, --numeric Ordenar los datos numericamente en vez de alfabeticamente.\n"
		"Examples:\n"
		"   qsort -n numeros.txt\n"
	);
}

void sort(char* input_file, char* output_file) {
	FILE* input;
	FILE* output;
	if (!input_file && !output_file) {
		input = stdin;
		output = stdout;
	} else {
		input = fopen(input_file, "r");
		output = fopen(output_file, "w");
	}
	if (!input || !output) return;
	
	size_t read_size;
	
	
	fclose(input);
	fclose(output);
}

int main (int argc, char *argv[]) {
	bool help, version, output, input;
	help = version = output = input = false;
	char *output_file, *input_file;
	output_file = input_file = NULL;
	int flag = 0;
	struct option opts[] = {
		{"version", no_argument, 0, 'V'},
		{"help", no_argument, 0, 'h'},
		{"output", required_argument, 0, 'o'},
		{"input", required_argument, 0, 'i'}
	};

	while ((flag = getopt_long(argc, argv, "Vho:i:d", opts, NULL)) != -1) {
		switch (flag) {
			case 'V' :
				version = true;
				break;
			case 'h' :
				help = true;
				break;
			case 'o' :
				output_file = optarg;
				output = true;
				break;
			case 'i' :
				input_file = optarg;
				input = true;
				break;
		}
	}

	if (help) {
		show_help();
	} else if (version) {
		show_version();
	} else {
		sort(input_file, output_file);		
	}
	return EXIT_SUCCESS;
}
