/*
 * Copyright (c) 2021 Ali Farzanrad <ali_farzanrad@riseup.net>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
 * WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS.  IN NO EVENT SHALL THE
 * AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
 * DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR
 * PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
 * TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 */
%{
#include <ctype.h>
#include <err.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define STRSIZE 63
#define YYSTYPE char *
#define yyerror warnx

static int	 yylex(void);
%}

%token APO_S, APO_M, APO_RE, APO_NT,
NOUN, TO_BE, ACTION,
WHEN, WHERE, WHICH, WHO, WHAT,
ARTICLE, POSSESSIVE, DEMONSTRATIVE, HER

%%

grammar:	/* empty */
		| grammar '\n'
		| grammar sentence '.' '\n' { printf("%s.\n", $2); free($2); }
		| grammar question '?' '\n' { printf("%s\xd8\x9f\n", $2); free($2); }
		;

sentence:	subject predicate	{ asprintf(&$$, "%s %s", $1, $2); free($1); free($2); }
		;

question:	WHEN TO_BE noun_phrase	{ asprintf(&$$, "%s\xd9\x87 %s", $3, $1); free($1); free($2); free($3); }
		| WHERE TO_BE noun_phrase	{ asprintf(&$$, "%s %s\xd8\xb3\xd8\xaa", $3, $1); free($1); free($2); free($3); }
		| WHICH noun_phrase TO_BE noun_phrase { asprintf(&$$, "%s %s %s %s", $1, $2, $4, $3); free($1); free($2); free($3); free($4); }
		| WHO TO_BE noun_phrase	{ asprintf(&$$, "%s %s\xd9\x87", $3, $1); free($1); free($2); free($3); }
		| WHAT TO_BE noun_phrase { asprintf(&$$, "%s \xda\x86\xdb\x8c\xd8\xb3\xd8\xaa", $3); free($1); free($2); free($3); }
		| WHAT noun_phrase TO_BE noun_phrase { asprintf(&$$, "%s %s %s\xdb\x8c\xd9\x87", $4, $1, $2); free($1); free($2); free($3); free($4); }
		;

subject:	noun_phrase
		;

predicate:	verb object		{ asprintf(&$$, "%s %s", $2, $1); free($1); free($2); }
		;

object:		noun_phrase
		;

noun_phrase:	noun
		| ARTICLE noun		{ asprintf(&$$, "%s%s", $2, $1); free($1); free($2); }
		| POSSESSIVE noun	{ asprintf(&$$, "%s%s", $2, $1); free($1); free($2); }
		| HER noun		{ asprintf(&$$, "%s\xd8\xb4", $2); free($1); free($2); }
		| noun APO_S noun	{ asprintf(&$$, "%s %s", $3, $1); free($1); free($3); }
		| DEMONSTRATIVE noun	{ asprintf(&$$, "%s %s", $2, $1); free($1); free($2); }
		;

noun:		NOUN
		| HER			{ $$ = strdup("\xd8\xa7\xd9\x88"); free($1); }
		;

verb:		TO_BE | ACTION
		| APO_M			{ $$ = strdup("\xd9\x87\xd8\xb3\xd8\xaa\xd9\x85"); free($1); }
		| APO_S			{ $$ = strdup("\xd9\x87\xd8\xb3\xd8\xaa"); free($1); }
		| APO_RE		{ $$ = strdup("\xd9\x87\xd8\xb3\xd8\xaa\xdb\x8c\xd8\xaf"); free($1); }
		;

%%

struct translation {
	int		 token;
	const char	*name;
	const char	*trans;
} translation[] = {
	{ARTICLE,	"a",		"\xdb\x8c"},
	{ARTICLE,	"an",		"\xdb\x8c"},
	{ARTICLE,	"the",		""},
	{NOUN,		"I",		"\xd9\x85\xd9\x86"},
	{NOUN,		"me",		"\xd9\x85\xd9\x86"},
	{POSSESSIVE,	"my",		"\xd9\x85"},
	{NOUN,		"mine",		"\xd9\x85\xd8\xa7\xd9\x84 \xd9\x85\xd9\x86"},
	{NOUN,		"we",		"\xd9\x85\xd8\xa7"},
	{NOUN,		"us",		"\xd9\x85\xd8\xa7"},
	{POSSESSIVE,	"our",		"\xd9\x85\xd8\xa7\xd9\x86"},
	{NOUN,		"ours",		"\xd9\x85\xd8\xa7\xd9\x84 \xd9\x85\xd8\xa7"},
	{NOUN,		"you",		"\xd8\xb4\xd9\x85\xd8\xa7"},
	{POSSESSIVE,	"your",		"\xd8\xaa\xd8\xa7\xd9\x86"},
	{NOUN,		"yours",	"\xd9\x85\xd8\xa7\xd9\x84 \xd8\xb4\xd9\x85\xd8\xa7"},
	{NOUN,		"he",		"\xd8\xa7\xd9\x88"},
	{NOUN,		"him",		"\xd8\xa7\xd9\x88"},
	{POSSESSIVE,	"his",		"\xd8\xb4"},
	{NOUN,		"she",		"\xd8\xa7\xd9\x88"},
	{HER,		"her",		""},
	{NOUN,		"hers",		"\xd9\x85\xd8\xa7\xd9\x84 \xd8\xa7\xd9\x88"},
	{NOUN,		"they",		"\xd8\xa2\xd9\x86\xd9\x87\xd8\xa7"},
	{NOUN,		"them",		"\xd8\xa2\xd9\x86\xd9\x87\xd8\xa7"},
	{POSSESSIVE,	"their",	"\xd8\xb4\xd8\xa7\xd9\x86"},
	{NOUN,		"theirs",	""},
	{TO_BE,		"am",		"\xd9\x87\xd8\xb3\xd8\xaa\xd9\x85"},
	{TO_BE,		"is",		"\xd9\x87\xd8\xb3\xd8\xaa"},
	{TO_BE,		"are",		"\xd9\x87\xd8\xb3\xd8\xaa\xdb\x8c\xd8\xaf"},
	{WHEN,		"when",		"\xda\xa9\xdb\x8c"},
	{WHERE,		"where",	"\xda\xa9\xd8\xac\xd8\xa7"},
	{WHICH,		"which",	"\xda\xa9\xd8\xaf\xd8\xa7\xd9\x85"},
	{WHO,		"who",		"\xda\xa9\xdb\x8c"},
	{WHAT,		"what",		"\xda\x86\xd9\x87"},
	{NOUN,		"one",		"\xdb\x8c\xda\xa9"},
	{NOUN,		"color",	"\xd8\xb1\xd9\x86\xda\xaf"},
	{NOUN,		"name",		"\xd8\xa7\xd8\xb3\xd9\x85"},
	{NOUN,		"book",		"\xda\xa9\xd8\xaa\xd8\xa7\xd8\xa8"},
	{0, "", ""}
};
int	 translation_len;

int
translationcmp(const void *x, const void *y)
{
	const struct translation *p = x, *q = y;
	return strcasecmp(p->name, q->name);
}

static int
yylex(void)
{
	int		 c = getchar();
	char		 buf[64];

	if (c == '\'') {
		int res;
		switch (getchar()) {
		case 's':
			res = APO_S;
			break;
		case 'm':
			res = APO_M;
			break;
		case 'r':
			if (getchar() != 'e')
				errx(1, "syntax error");
			res = APO_RE;
			break;
		case 'n':
			if (getchar() != 't')
				errx(1, "syntax error");
			res = APO_NT;
			break;
		default:
			errx(1, "syntax error");
		}
		c = getchar();
		if (c != EOF && !isspace(c))
			errx(1, "syntax error");
		return res;
	}

	while (c == ' ' || c == '\t')
		c = getchar();

	if (c == EOF)
		return 0;
	if (isalpha(c)) {
		int i = 0;
		while (i < (int)sizeof(buf) && isalpha(c)) {
			buf[i++] = c;
			c = getchar();
		}
		if (i == (int)sizeof(buf))
			errx(1, "too big word");
		ungetc(c, stdin);
		buf[i] = 0;
		fflush(stdout);
		int low = 0, high = translation_len;
		while (low < high) {
			int mid = (low + high) / 2;
			int res = strcasecmp(translation[mid].name, buf);
			if (res < 0)
				low = mid + 1;
			else if (res > 0)
				high = mid;
			else {
				yylval = strdup(translation[mid].trans);
				return translation[mid].token;
			}
		}
		yylval = strdup(buf);
		return NOUN;
	}
	return c;
}

int
main(void)
{
	translation_len = 0;
	while (translation[translation_len].name[0])
		++translation_len;
	qsort(translation, translation_len, sizeof(translation[0]), translationcmp);
	yyparse();
	return 0;
}
