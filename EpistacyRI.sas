*--------------------------------EPISTACYRI.sas ----------------------------*
|                                                                           |
|   A SAS program to detect epistatic interactions among locus pairs based  |
|   on genetic marker data and phenotypic data in recombinant inbred or     |
|   doubled haploid populations.                                            |
|   Version 2.0.  Updated May 30, 2001.                                     |                                                            |
|                                                                           |
|   Written by Jim Holland, USDA-ARS, Department of Crop Science,           |
|   North Carolina State University, Raleigh, NC 27695                      |
|   and Harsha Ingle, The Bayer Corporation, Clayton, NC.                   |
|                                                                           |
*---------------------------------------------------------------------------;

*----------------------------------------------------------------------------
* Before implementing the epistacy program, the genotypic and phenotypic data
* should be organized in a data file in a manner that can be processed easily
* by SAS.  Generally, each line or genotype should be listed in rows, the
* genetic data from the different marker loci listed in columns, and the
* dependent phenotypic data also listed in columns. In addition, a data file
* with a list of the names of all loci to be analyzed must be included.
*
* It is assumed that the marker data are codominant, so that heterozygotes
* can be distinguished, or that doubled haploids are used, in which case
* dominant markers can be used.  In this version of the program,
* heterozygotes are eliminated from the analysis, and additive-by-additive
* epistasis only is tested.  For F2 data, where heterozygotes occur
* frequently and in the same generation from which the phenotypic data
* derive, there is a companion version of the program - "EpistacyF2.sas" - which
* will analyze each locus pair for additive-by-additive, additive-by
* dominant, and dominant-by-dominant epistasis.
*
* It is also assumed that the genotypic data are coded 0 = homozygous for
* parent A allele, 1 = heterozygous, and 2 = homozygous for parent B allele.
* Other codings are possible, but the program will have to be modified, as
* done in the example program - ExampleRI.sas.
*---------------------------------------------------------------------------;

*----------------------------------------------------------------------------
* Begin by setting options to determine the look of the output.  Here, it is
* chosen to have the output printed to pages sized 76 lines long and 64
* characters wide, without centering.
*
* IMPORTANT NOTE FOR MAINFRAME USERS: If you attempt to run "epistacy" as a
* batch job on a mainframe system, the log file created by the program will
* become too large and will cause the program to exit without completing
* execution.  To avoid this, include the options "nosource" and "nonotes"
* here.  Only include these options after ensuring that the program functions
* on a small subset of the marker loci - otherwise you will have no error
* messages to guide troubleshooting.
*
* IMPORTANT NOTE FOR SAS V. 8.0 FOR WINDOWS USERS:
* Run the program from the regular program editor window, NOT the enhanced
* program editor window.
*---------------------------------------------------------------------------;

options nocenter ls=76 ps=64;

*----------------------------------------------------------------------------
* Read in the dataset with the list of genetic marker loci and create a
* macro variable "nummark" which is the total number of markers. If the list
* of loci is in a single column of a worksheet called "Loci" in an OPEN Excel
* spreadsheet called "DataFile.xls" then it can be read with the following
* commands.  If reading from some other file format, these commands will
* have to be changed.
*---------------------------------------------------------------------------;

data loci;
FILENAME DATA1 DDE "EXCEL|[DataFile.xls]Loci!R1C1:R100C1";
INFILE DATA1 NOTAB DLM= '09'X DSD MISSOVER lrecl = 10240;
input locname $;

N=_n_;
call symput ('nummark', trim(left(N)));
run;


proc sort data=loci;
by locname;
run;

* Create macro variables genmark1-genmark(&nummark)for
each unique genetic marker (locus);

data a;
set loci;
by locname;
if first.locname then do;
i+1;
put locname=   ;
ii=left(put(i,3.));
/* if you have more than 999 loci, increase the 3. to 4. for up to 10,000 markers, etc...*/
call symput ('genmark'||ii, trim(upcase(locname)));
end;
run;
%put _user_; * Displays the macro variables in the log window;


*----------------------------------------------------------------------------
* Input the data from an external file or data set. For example, assume the
* data are in an OPEN Excel spreadsheet file called "DataFile.xls", in a
* worksheet within that file called "Sheet1" and in rows 1 - 200 and columns
* 1 - 100 of the worksheet. Then, the data can be inputted with the following
* commands.
*---------------------------------------------------------------------------;

data all;
FILENAME DATA1 DDE "EXCEL|[DataFile.xls]Sheet1!R1C1:R200C100";
INFILE DATA1 NOTAB DLM= '09'X DSD MISSOVER lrecl = 10240;

*----------------------------------------------------------------------------
* List the dependent and independent variables in the order in which they are
* listed in the data file.  For example, if the first column had the progeny
* designation number, the second column had the genotypic information for locus1,
* the third had genotypic data from locus2, etc... until the last columns
* which have the phenotypic data, the following type of command would be used:
*---------------------------------------------------------------------------;

input progeny locus1 locus2 locus3 locus4 .... trait1 trait 2 ...;
if progeny = "." then delete; proc print;

*----------------------------------------------------------------------------
* Macro "transform" eliminates heterozygous marker data points by making
* them into missing data points.  If heterozygotes are coded as "1", they
* will be transformed to "." by this macro.
*---------------------------------------------------------------------------;

%macro transform(dataset);
        data &dataset; set &dataset;
        %do i = 1 %to &nummark;
                if &&genmark&i  = 1 then &&genmark&i  = ".";
        %end;
%mend transform;

*invoke the transform macro for data set "one";
%transform(all);

* Create work sets that are empty to clear any residual memory;

data selects;
data output;
data means;
data empty;

*----------------------------------------------------------------------------
* Macro RI uses proc glm to perform the analysis of variance for each
* locus pair.
* Use the following options to help de-bug the macro if necessary:
* options mprint symbolgen mlogic;
*---------------------------------------------------------------------------;

%macro ri(trait, pvalue);
%do i=1 %to &nummark -1;

dm log 'clear' continue;

     %do j=&i+1 %to &nummark;
          proc glm data=all outstat=out noprint;
          class &&genmark&i &&genmark&j;
          model &trait = &&genmark&i &&genmark&j &&genmark&i*&&genmark&j;
          lsmeans &&genmark&i*&&genmark&j/noprint out=mns;
          run;

          data check; set out; if upcase(_source_) = "&&genmark&i*&&genmark&j"
          and _type_ = "SS3";
          if prob le &pvalue then call symput("SELECT","YES");
          else call symput("SELECT", "NO");
          data check; set check;
          %if &select = YES
          %then %do;
                data out;length locus1 locus2 $12; set out;
                locus1 = "&&genmark&i";locus2 = "&&genmark&j";
                rename _name_ = trait;
                if upcase(_source_) = "&&genmark&i" then _source_ = "M1";
                if upcase(_source_) = "&&genmark&j" then _source_ = "M2";
                if upcase(_source_) = "&&genmark&i*&&genmark&j" then _source_ = "INT";

                data output; set output out;

                data mns;length locus1 locus2 $12; set mns;
                locus1 = "&&genmark&i";locus2 = "&&genmark&j";
                rename &&genmark&i = geno1 &&genmark&j = geno2;

                data means; set means mns;

                data ds1 ds2 ds3;set output;
                if _type_ = "ERROR" then output ds1;
                if _type_ = "SS3" then output ds2;
                if _type_ = "SS1" then output ds3;

                data ds1; set ds1;
                rename df=dferr ss=sserr; drop f prob;
                proc sort; by locus1 locus2;

                data ds2; set ds2;if _source_ = "INT";
                rename df=dfint ss=ssint f = fint prob = probint;
                proc sort; by locus1 locus2;

                data a; set ds3; if _source_ = "M1";
                 _type_ = "MODEL"; ssa = ss;
                data b; set ds3; if _source_ = "M2";
                _type_ = "MODEL"; ssb=ss;
                data c; set ds3; if _source_ = "INT";
                _type_ = "MODEL"; ssc=ss;
                data model; merge a b c; by _type_; ssmod = ssa+ssb+ssc;
                proc sort; by locus1 locus2;

                data ds4; merge ds1 ds2 model; by locus1 locus2;
                sstotal = sserr+ssmod;partr2 = ssint/sstotal;
                drop ss ssa ssb ssc f prob df _source_ _type_;

                data geno1; set means;if geno1 = 0 and geno2 = 0; geno00 = lsmean;
                proc sort; by locus1 locus2;
                data geno3; set means;if geno1 = 0 and geno2 = 2; geno02 = lsmean;
                proc sort; by locus1 locus2;
                data geno7; set means;if geno1 = 2 and geno2 = 0; geno20 = lsmean;
                proc sort; by locus1 locus2;
                data geno9; set means;if geno1 = 2 and geno2 = 2; geno22 = lsmean;
                proc sort; by locus1 locus2;
                data allgeno; merge geno1 geno3 geno7 geno9; by locus1 locus2;
                rename _name_ = trait; drop stderr lsmean geno1 geno2;
                data ds4; merge ds4 allgeno; by locus1 locus2;
                if dfint = 0 then delete;
                proc sort; by locus1 locus2; run;

                data selects; set selects ds4;
                data output; set empty;
                data means; set empty;
                %end; /*ends commands invoked when p-value of interaction is < threshold*/

           %end;  /*end i do loop*/

%end;  /* end j do-loop*/
%mend ri;

*Invoke the RI macro for variables "trait1" and "trait2" and 
p-value = 0.001;

%ri(trait1, 0.001);
%ri(trait2, 0.001);
run;

*print the output;

data selects; set selects; if dfint ne ".";
proc print; run;


