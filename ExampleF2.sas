*--------------------------------ExampleF2.sas------------------------------*
|                                                                           |
|   An example SAS program to detect epistatic interactions among locus     |
|   pairs based on genetic marker data and phenotypic data in an F2 maize   |
|   population with 150 individuals. Each plant was genotyped at 114        |
|   codominant marker loci and also measured for plant height.  Data were   |
|   kindly supplied by D. Asmono and M. Lee, Iowa State University for use  |
|   with this example program.                                              |
|   Version 2.0 Updated May 30, 2001                                        |
|                                                                           |
|                                                                           |
|   Written by Jim Holland, USDA-ARS, Department of Crop Science,           |
|   North Carolina State University, Raleigh, NC 27695                      |
|   and Harsha Ingle, The Bayer Corporation, Clayton, NC.                   |
|                                                                           |
*---------------------------------------------------------------------------;

*---------------------------------------------------------------------------;

*----------------------------------------------------------------------------
* Before implementing the epistacy program, the genotypic and phenotypic data
* should be organized in a separate data file in a manner that can be
* processed easily by SAS.  Generally, each line or genotype should be listed
* in rows, the genetic data from the different marker loci listed in columns,
* and the dependent phenotypic data also listed in columns.  This program
* analyzes one trait at a time, although it could be modified to analyze
* multiple traits.
*
* It is assumed that the marker data are codominant, so that heterozygotes
* can be distinguished. For recombinant inbred or doubled haploid data, there
* is a companion version of the program - "epistacy.ri" - which will analyze
* each locus pair for additive-by-additive epistasis.
*
* It is also assumed that the genotypic data are coded 0 = homozygous for
* parent A allele, 1 = heterozygous, and 2 = homozygous for parent B allele.
* Other codings are possible, but the program will have to be modified, as
* done later in this example program.
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
*---------------------------------------------------------------------------;

options nocenter ls=76 ps=64;

*----------------------------------------------------------------------------
* The data are maintained in two external files, "mo17rflp.txt" and
* "mo17rfl2.txt".  Input the two files and combine them into a single data
* set, named "all", using the set command in SAS.  Note that the loci used in
* this data set include loci with names like "BNL6.32".  SAS will not accept
* a variable name with a "." character in it.  Therefore, all "." characters
* in locus names have been changed to "z" in the input commands and
* throughout the rest of the program.   It is assumed that all
* files are on the root "C:" directory.  If otherwise, the correct directory
* must be specified in each "infile" statement.  If the program is run on a
* system other than PC-SAS the directory identification will need to be
* altered to suit the system used.
*---------------------------------------------------------------------------;
data loci;
FILENAME ALLLOCI DDE "EXCEL|[MaizeData.xls]MaizeLoci!R1C1:R114C1";
INFILE ALLLOCI NOTAB DLM= '09'X DSD MISSOVER lrecl = 10240;
input locname $;

N=_n_;
call symput ('nummark', trim(left(N)));
run;

proc sort data=loci;
by locname;
run;


* Creates macro variables genmark1-genmark(&nummark)for
each unique genetic marker;

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

data one;
FILENAME one DDE "EXCEL|[MaizeData.xls]MaizeF2a!R2C1:R151C65";
INFILE one NOTAB DLM= '09'X DSD MISSOVER lrecl = 10240;
input PROG UMC94 $ UMC164 $ UMC157 $ NPI234 $ UMC13 $ P1 $ NPI429 $ NPI236 $
UMC37 $ PANXX2z3 $ ISU018 $ ISU019A $ ISU006 $ UMC86A $ BNL6z32 $ UMC53 $
UMC78 $ UMC131 $ UMC98A $ UMC4 $ BNL8z44B $ BNL8z15 $ UMC121 $ BNL8z35 $
UMC26 $ BNL3z18 $ Sh2 $ UMC123 $ PIO20713 $ BNL5z46 $ Bt2 $ NPI292 $ PIO10z25
$ UMC111 $ UMC86B $ BNL6z25 $ UMC72 $ UMC27 $ BNL10z06 $ Bt1 $ BNL10z12 $
ISU019B $ UMC51 $ UMC68  $ NPI235 $ UMC65 $ PL1 $ UMC21 $ NPI280 $ UMC62 $
AGP1 $ BNL15z40 $ UMC98B $ UMC110 $ BNL7z61 $ BNL8z39 $ BNL8z44A $ UMC35 $
BNL9z11 $ UMC103 $ BNL9z08 $ UMC48 $ NPI268 $ UMC7 $;

data two;
FILENAME two DDE "EXCEL|[MaizeData.xls]MaizeF2b!R2C1:R151C65";
INFILE two NOTAB DLM= '09'X DSD MISSOVER lrecl = 10240;
input PROG  C1 $ BNL3z06 $ UMC153 $ BNL8z17 $ BNL14z28 $ NPI209 $ UMC64 $ ISU005 $
ISU012 $ NPI287 $ ISU049 $ ISU040 $  ISU064 $ ISU104 $ ISU141 $ ISU169  $
ISU98 $ ISU119 $ ISU150 $ ISU133 $ ISU115 $ ISU036 $ ISU069 $ ISU109 $ ISU120
$ ISU139 $ ISU116 $ ISU074 $ ISU152 $ ISU124 $ ISU136A $ ISU136B $ ISU032 $
ISU088 $ ISU045 $ ISU048 $ ISU075 $ ISU147 $ ISU138 $ ISU093 $ ISU058 $
ISU047 $ ISU046 $ ISU100 $ ISU053 $ ISU021 $ ISU132A $ ISU132B $ ISU168A $
UMC165 $ PLHT;

data all; merge one two; by prog;
proc print;

run;

data all; merge one two; by prog;
proc print; run;

*create work sets that are empty to clear any residual memory;
data selects;
data output;
data means;
data empty;

*macro f2 performs anova for each pair of loci;
*options mprint symbolgen mlogic;
%macro f2(trait, pvalue);
%do i=1 %to &nummark -1;

dm log 'clear' continue;

     %do j=&i+1 %to &nummark;
          proc glm data=all outstat=out noprint;
          class &&genmark&i &&genmark&j;
          model &trait = &&genmark&i &&genmark&j &&genmark&i*&&genmark&j;

          contrast "AxA" &&genmark&i*&&genmark&j 1 -1 0 -1 1 0 0 0 0;
          contrast "AxD" &&genmark&i*&&genmark&j 1 1 -2 -1 -1 2 0 0 0;
          contrast "DxA" &&genmark&i*&&genmark&j 1 -1 0 1 -1 0 -2 2 0;
          contrast "DxD" &&genmark&i*&&genmark&j 1 1 -2 1 1 -2 -2 -2 4;

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
                rename _name_ = &trait;
                if upcase(_source_) = "&&genmark&i" then _source_ = "M1";
                if upcase(_source_) = "&&genmark&j" then _source_ = "M2";
                if upcase(_source_) = "&&genmark&i*&&genmark&j" then _source_ = "INT";

                data output; set output out;

                data mns;length locus1 locus2 $12; set mns;
                locus1 = "&&genmark&i";locus2 = "&&genmark&j";
                rename &&genmark&i = geno1 &&genmark&j = geno2;

                data means; set means mns;

                data ds1 ds2 ds3 dscont;set output;
                if _type_ = "ERROR" then output ds1;
                if _type_ = "SS3" then output ds2;
                if _type_ = "SS1" then output ds3;
                if _type_ = "CONTRAST" then output dscont;

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


                data axa; set dscont; if _source_ = "AxA";
                rename ss = ssaxa f = faxa prob = probaxa;
                proc sort; by locus1 locus2;
                data axd; set dscont; if _source_ = "AxD";
                rename ss = ssaxd f = faxd prob = probaxd;
                proc sort; by locus1 locus2;
                data dxa; set dscont; if _source_ = "DxA";
                rename ss = ssdxa f = fdxa prob = probdxa;
                proc sort; by locus1 locus2;
                data dxd; set dscont; if _source_ = "DxD";
                rename ss = ssdxd f = fdxd prob = probdxd;
                proc sort; by locus1 locus2;


                data ds4; merge ds1 ds2 model axa axd dxa dxd; by locus1 locus2;
                sstotal = sserr+ssmod;partr2 = ssint/sstotal;
                drop df  _source_ _type_;

                data geno1; set means;if geno1 = "A" and geno2 = "A"; geno00 = lsmean;
                proc sort; by locus1 locus2;
                data geno2; set means;if geno1 = "A" and geno2 = "H"; geno01 = lsmean;
                proc sort; by locus1 locus2;
                data geno3; set means;if geno1 = "A" and geno2 = "B"; geno02 = lsmean;
                proc sort; by locus1 locus2;
                data geno4; set means;if geno1 = "H" and geno2 = "A"; geno10 = lsmean;
                proc sort; by locus1 locus2;
                data geno5; set means;if geno1 = "H" and geno2 = "H"; geno11 = lsmean;
                proc sort; by locus1 locus2;
                data geno6; set means;if geno1 = "H" and geno2 = "B"; geno12 = lsmean;
                proc sort; by locus1 locus2;
                data geno7; set means;if geno1 = "B" and geno2 = "A"; geno20 = lsmean;
                proc sort; by locus1 locus2;
                data geno8; set means;if geno1 = "B" and geno2 = "H"; geno21 = lsmean;
                proc sort; by locus1 locus2;
                data geno9; set means;if geno1 = "B" and geno2 = "B"; geno22 = lsmean;
                proc sort; by locus1 locus2;

                data allgeno; merge geno1 geno2 geno3 geno4 geno5 geno6 geno7
                geno8 geno9;by locus1 locus2;
                rename _name_ = trait; drop stderr lsmean geno1 geno2;data geno1; set means;if geno1 = 0 and geno2 = 0; geno00 = lsmean;

                data ds4; merge ds4 allgeno; by locus1 locus2;
                if dfint = 0 then delete;
                proc sort; by locus1 locus2; run;

                data selects; set selects ds4;
                data output; set empty;
                data means; set empty;
                %end; /*ends commands invoked when p-value of interaction is < threshold*/

           %end;  /*end i do loop*/

%end;  /* end j do-loop*/
%mend glm;

%f2(plht, 0.001);

data selects; set selects; if dfint ne ".";
proc print; run;
run;
