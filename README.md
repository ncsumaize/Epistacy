# Epistacy
Ancient SAS code for genetic epistasis search

EPISTACY: A SAS program for detecting two-locus epistatic interactions using genetic marker information

VERSION 2.0 Links below are for updated version 2.0 files.

Comments 20 years after publishing this code: I am keeping this up for legacy purposes. I don't recommend using this cose, the epistasis search algorithms in R/QTL and QTL Cartographer, are much better.

EPISTACY is a SAS program designed to test all possible two-locus combinations for epistatic (interaction) effects on a quantitative trait using QTL-mapping data sets.

The program is really a SAS program template that users must modify to suit their own data sets. In the simplest cases, users will need only to change the names of the files containing their data.  The program uses least squares methods and does not employ interval mapping methods.  The software is free to all.  If you use the software and find it useful, please send me an email to let me know.  Also, if you have problems or suggestions for improvement, let me know.  I will post updates here as they are developed.  You can reference the program for publication as Journal of Heredity 1998, Vol 89:374-375.

1 To start with, please read the UPDATED introduction and manual, available in PDF format.  You can download and print the manual on your own machine.

2 After reading the introduction, choose the program suitable for your type of population.  You can download to your own computer, save as a text file, and use that directly as the program file to run under the SAS system.  As described in the manual, you will need to modify the program to suit your data set by changing the data file names and the names of the marker loci to be tested.
 
    If you want to analyze data from an F2 or F2-derived population, choose EpistacyF2.sas
    If you want to analyze data from a recombinant inbred line population, choose EpistacyRI.sas

3 Download example programs and data sets to see how the programs work:
 
    ExampleF2.sas is a program to analyze actual data from a maize F2 population.  In addition to the program, you need to download one Excel spreadsheet data file: MaizeF2Data.xls.
    ExampleRI.sas is a program to analyze actual data from an oat recombinant inbred population.  In addition to the program, you need to download one Excel spreadsheet data file: RILExampleData.xls.
