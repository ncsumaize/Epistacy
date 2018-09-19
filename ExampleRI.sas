*--------------------------------ExampleRI.sas------------------------------*
|                                                                           |
|   Example program to implement genome-wide search for epistasis using     |
|   the trait days to heading measured in Aberdeen, ID on 84 recombinant    |
|   inbred lines of oats.  Data are available on the World Wide Web from    |
|   the Journal of Quantitative Trait Loci and were reported in             |
|   Siripoonwiwat, W., L.S. O'Donoughue, D.Wesenberg, D.L. Hoffman, J.F.    |
|   Barbosa-Neto, and M.E. Sorrells. 1996. Chromosomal regions associated   |
|   with quantitative traits in oat. J. Quantitative Trait Loci 2,          |
|   Article 3. http://probe.nalusda.gov:8000/otherdocs/jqtl/.               |
|                                                                           |
|   Acknowledgement is given to the authors for their kind permission to    |
|   use these data as an example data set.                                  |
|                                                                           |
|                                                                           |
|   Version 2.0 Updated May 30, 2001                                        |
|                                                                           |
|                                                                           |
|   Written by Jim Holland, USDA-ARS, Department of Crop Science,           |
|   North Carolina State University, Raleigh, NC 27695                      |
|   and Harsha Ingle, The Bayer Corporation, Clayton, NC.                   |
|                                                                           |
*---------------------------------------------------------------------------;

options nocenter ls=76 ps=64;

*----------------------------------------------------------------------------
* The genotypic data are maintained in a single Excel spreadsheet file called
* "RILExampleData.xls".  Within this file, there are five separate worksheets
* ("RFLPA", "RFLPB", etc..) because of the large size of the data
* set.  Each worksheet is to be input into its own working data set in SAS, named
* "rflpa", "rflpb", etc., then the separate data sets will be combined into a
* single data set using the "set" command in SAS. Also there is a sixth
* worksheet with the trait data ("Traits") and a worksheet with the list of
* the names of ALL loci to be analyzed ("OatLoci").  The spreadsheet must be
* OPEN for the data to be read in this way.  Alternatively, the data can
* be saved in text files and read fromthe hard drive using a different form
* of the "infile" command.
*---------------------------------------------------------------------------;

* Read in dataset with the list of genetic marker loci and create a macro
nummark which is the total number of markers;

data loci;
FILENAME DATA1 DDE "EXCEL|[RILExampleData.xls]OatLoci!R1C1:R252C1";
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

*read in genotypic data set in five parts;

data rflpa;
FILENAME DATA1 DDE "EXCEL|[RILExampleData.xls]RFLPA!R2C1:R85C52";
INFILE DATA1 NOTAB DLM= '09'X DSD MISSOVER lrecl = 10240;
input ril avn3 BCD1049 BCD1108 BCD1117 BCD115A
BCD1160 BCD1184 BCD1186 BCD1230B BCD1235 BCD1237 BCD1250 BCD1261A
BCD1265 BCD127 BCD1270 BCD1280A BCD1307 BCD1338A BCD1380A BCD1405
BCD1407 BCD1532A BCD1532B BCD1555 BCD1580 BCD1643A BCD1660 BCD1695
BCD1716A BCD1716B BCD1734 BCD1779 BCD1797A BCD1797C BCD1802 BCD1823A
BCD1829B BCD1851C BCD1856 BCD1860 BCD1871 BCD1872A BCD1872B BCD1876
BCD1882B BCD1882C BCD1897A BCD1931 BCD1950A BCD1950B;
if ril = "." then delete;

data rflpb;
FILENAME DATA2 DDE "EXCEL|[RILExampleData.xls]RFLPB!R2C1:R85C53";
INFILE DATA2 NOTAB DLM= '09'X DSD MISSOVER lrecl = 10240;
input ril BCD1968B BCD1968C
BCD269 BCD327 BCD342A BCD421A BCD454 BCD808A BCD897 BCD907 BCD961
BCD978 CDO1081 CDO1090C CDO1091 CDO1092 CDO1168A CDO1174A CDO1192A
CDO1192B CDO1196 CDO1199A CDO122 CDO1238 CDO1242 CDO1246A CDO1281
CDO1313 CDO1319A CDO1319B CDO1321A CDO1326 CDO1328 CDO1340 CDO1342
CDO1345 CDO1358 CDO1378A CDO1378B CDO1380 CDO1388 CDO1396 CDO1402A
CDO1403A CDO1403B CDO1407B CDO1414B CDO1419 CDO1423B CDO1428A
CDO1428B
CDO1430;if ril = "." then delete;

data rflpc;
FILENAME DATA3 DDE "EXCEL|[RILExampleData.xls]RFLPC!R2C1:R85C58";
INFILE DATA3 NOTAB DLM= '09'X DSD MISSOVER lrecl = 10240;
input ril CDO1433 CDO1435B CDO1435C CDO1436C CDO1437B CDO1445A CDO1445B
CDO1454 CDO1464 CDO1466 CDO1467A CDO1471 CDO1495 CDO1509A CDO1509C
CDO1510 CDO1523A CDO1523B CDO187 CDO189 CDO220 CDO278 CDO304 CDO309A
CDO346B CDO348B CDO370 CDO373 CDO393D CDO395A CDO405 CDO412A CDO414
CDO420B CDO457A CDO460A CDO460B CDO480 CDO482A CDO482C CDO482D
CDO484A CDO539B CDO54 CDO542 CDO549A CDO57A CDO57C CDO57D CDO580
CDO585B CDO58A CDO58B CDO58C CDO590A CDO590B CDO595;
if ril = "." then delete;

data rflpd;
FILENAME DATA4 DDE "EXCEL|[RILExampleData.xls]RFLPD!R2C1:R85C52";
INFILE DATA4 NOTAB DLM= '09'X DSD MISSOVER lrecl = 10240;
input ril CDO608A CDO618A  CDO638 CDO665A CDO673A
CDO708A CDO708B CDO718B CDO770B CDO772 CDO780 CDO795A CDO795B CDO82
CDO942 CDO962A CDO962B ISU0563B ISU0582A ISU0582B ISU1146A ISU1163
ISU1247A ISU1254B ISU1372B ISU1450 ISU1463 ISU1543A ISU1651 ISU1736
ISU1755B ISU1774A ISU1874A ISU1900A ISU1900B ISU1958B ISU1961 ISU2013
ISU2124A ISU2192A ISU2287 KSUA1 OG49 PTA71A PTB17 PX5 R209A R221
SAD1 UMN101 UMN106;if ril = "." then delete;

data rflpe;
FILENAME DATA5 DDE "EXCEL|[RILExampleData.xls]RFLPE!R2C1:R85C42";
INFILE DATA5 NOTAB DLM= '09'X DSD MISSOVER lrecl = 10240;
input ril UMN107A UMN107B UMN109 UMN114 UMN128 UMN13
UMN133B UMN162 UMN202 UMN207A UMN214A UMN214B UMN23 UMN287
UMN339A
UMN339B UMN341A UMN361 UMN363A UMN364A UMN388 UMN407 UMN409 UMN41
UMN420 UMN433 UMN498A UMN498B UMN5004 UMN5047 UMN706B UMN815B
UMN826
UMN856A WG110B WG110C WG466 WG605 WG645 WG719A WG719B;
if ril = "." then delete;

data allrflp; merge rflpa rflpb rflpc rflpd rflpe; by ril;

*----------------------------------------------------------------------------
* The phenotypic data are maintained in a sixth worksheet, named
* "Traits".  This is only a portion of the phenotypic data measured by
* Siripoonwiwat et al. (1996), and includes only the trait heading date,
* measured in 7 different environments (Aberdeen, ID or Ithaca, NY, 1992-
* 1995).  For the purposes of this example, only the "hda92" trait will be
* analyzed.
*---------------------------------------------------------------------------;

data traits;
FILENAME DATA3 DDE "EXCEL|[RILExampleData.xls]Traits!R2C1:R85C8";
INFILE DATA3 NOTAB DLM= '09'X DSD MISSOVER lrecl = 10240;
input ril hda92 hda93 hda94 hda95 hdi93 hdi94 hdi95;

*----------------------------------------------------------------------------
* Finally, combine the genotypic and phenotypic data together in the data set
* "all" using the "merge" command in SAS.
*---------------------------------------------------------------------------;

data all; merge allrflp traits; by ril;

* Create work sets that are empty to clear any residual memory;

data selects;
data output;
data means;
data empty;

*----------------------------------------------------------------------------
* Before implementing the analysis on the loci, the data must be transformed
* into the format used by the program.  (Another option is to change the
* program to fit the data format.)  In the notation of Siripoonwiwat et al.,
* 0 = no data, 1 = homozygous for allele of parent 1, 2 = heterozygous, 3 =
* homozygous for allele of second parent.  The "transform" macro will transform
* the data into the standard program format"
* "." = no data, 0 = homozygous for allele of parent 1, 1 = heterozygous,
* 2 = homozygous for allele of second parent.
*
* In addition, this macro will eliminate heterozygous marker genotypes.  So,
* in fact, Siripoonwiwat's "2" class = our "1" class, which we then consider
* as missing data = "." class!
*
*---------------------------------------------------------------------------;

%macro transform(dataset);
        data &dataset; set &dataset;
        %do i = 1 %to &nummark;
                if &&genmark&i  = 0 then &&genmark&i  = ".";
                if &&genmark&i  = 1 then &&genmark&i  = 0;
                if &&genmark&i  = 2 then &&genmark&i  = ".";
                if &&genmark&i  = 3 then &&genmark&i  = 2;
        %end;
%mend transform;


%transform(all);

data all; set all; proc print;run;

* Macro "ri" is defined here, it will do the epistasis analysis;

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

*Invoke the RI macro for variable "hda92" and p-value = 0.001;

%ri(hda92, 0.001);
run;

*print the output;

data selects; set selects; if dfint ne ".";
proc print; run;
