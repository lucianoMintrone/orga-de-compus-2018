#include <stdbool.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <getopt.h>
#include <string.h>

#define MIN_LINES 128
#define MIN_LINE_LEN 100

void c_qsort(char **izq, char **der, int num);
void mips_qsort(char **izq, char **der, int num);

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
		"   -i, --input Archivo de entrada.\n"
		"   -n, --numeric Ordenar los datos numericamente en vez de alfabeticamente.\n"
		"Examples:\n"
		"   qsort -n numeros.txt\n"
	);
}

void print_result(char **result, int len, FILE *output_file) {
	size_t i;
	for (i = 0; i < len; i++) {
			fprintf(output_file, "%s\n", result[i]);
	}
}

void parse_file_sort_and_print(FILE *input_file, FILE *output_file, int num) {
	int lines_allocated = MIN_LINES;
	int max_line_len = MIN_LINE_LEN;

	/* Allocate lines of text */
	char **words = (char **)malloc(sizeof(char*)*lines_allocated);
	if (words==NULL) {
		fprintf(stderr,"Out of memory (1).\n");
		exit(1);
	}

	FILE *fp = input_file;
	if (fp == NULL) {
		fprintf(stderr,"Error opening file.\n");
		exit(2);
	}

	int i;
	for (i=0;1;i++) {
		int j;

		/* Have we gone over our line allocation? */
		if (i >= lines_allocated) {
			int new_size;

			/* Double our allocation and re-allocate */
			new_size = lines_allocated*2;
			words = (char **)realloc(words,sizeof(char*)*new_size);
			if (words==NULL) {
				fprintf(stderr,"Out of memory.\n");
				exit(3);
			}
			lines_allocated = new_size;
		}
		/* Allocate space for the next line */
		words[i] = malloc(max_line_len);
		if (words[i]==NULL) {
			fprintf(stderr,"Out of memory (3).\n");
			exit(4);
		}
		if (fgets(words[i],max_line_len-1,fp)==NULL)
			break;

		/* Get rid of CR or LF at end of line */
		for (j=strlen(words[i])-1;j>=0 && (words[i][j]=='\n' || words[i][j]=='\r');j--);
		words[i][j+1]='\0';
	}
	// Close file
	fclose(fp);

	mips_qsort(words, words + i - 1, num);
	print_result(words, i, output_file);

	// Free
	for (;i>=0;i--)
			free(words[i]);
	free(words);
}

int main (int argc, char *argv[]) {
	bool help, version, output, input, numeric;
	help = version = output = input = false;

	FILE *output_file, *input_file;
	output_file = input_file = NULL;

	int flag = 0;
	struct option opts[] = {
		{"version", no_argument, 0, 'V'},
		{"help", no_argument, 0, 'h'},
		{"numeric", no_argument, 0, 'n'},
		{"output", required_argument, 0, 'o'},
		{"input", required_argument, 0, 'i'}
	};

	while ((flag = getopt_long(argc, argv, "Vhno:i:d", opts, NULL)) != -1) {
		switch (flag) {
			case 'V' :
				version = true;
				break;
			case 'h' :
				help = true;
				break;
			case 'o' :
				if (!strcmp(optarg, "-")) {
					output_file = stdout;
				} else {
					output_file = fopen(optarg, "w");
				}
				output = true;
				break;
			case 'i' :
				input_file = fopen(optarg, "r");
				input = true;
				break;
			case 'n' :
				numeric = true;
				break;
		}
	}

	// Esto est'a dado vuelta porque soy medio boludo
	numeric = true;

	if (help) {
		show_help();
	} else if (version) {
		show_version();
	} else {
		parse_file_sort_and_print(input_file, output_file, numeric);
	}

	// fclose(input_file);
	// fclose(output_file);

	return EXIT_SUCCESS;
}
