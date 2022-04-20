* Encoding: UTF-8.

*Note: the following syntax allows for recreating tables 1-3 and appendix tables 1-2 using the 1972-2014 cumulative data set from the General Social Survey (see here: https://gss.norc.org). As described in the paper, 
missing values were imputed using a mulitiple imputation procedure. Thus, please note that differences in imputed values are expected and will result in small differences in results that use imputed data sets. 

*apply weight for black oversample.
WEIGHT BY oversamp.

*The following syntax includes recoded and computed variables used in the analysis.

*Cohort set up.
recode
cohort
(1900 thru 1909=0) (1910 thru 1919=1) (1920 thru 1929=2) (1930 thru 1939=3) (1940 thru 1949=4) (1950 thru 1959=5) (1960 thru 1969=6) (1970 thru 1979=7) (1980 thru 1991=8) (else=sysmis) into decades.
execute.
value labels
decades
0 '1900s'
1 '1910s'
2 '1920s'
3 '1930s'
4 '1940s'
5 '1950s'
6 '1960s'
7 '1970s'
8 '1980s'.

*recode of cohort variable that excludes 1900s. This is the cohort variable that was ultimately used in the analysis.
compute decadest = decades - 1.
execute.
value labels
decadest
0 '1910s'
1 '1920s'
2 '1930s'
3 '1940s'
4 '1950s'
5 '1960s'
6 '1970s'
7 '1980s'.

*As specified in the paper, the following respondents have been filtered out of the dataset for the analysis: born prior to 1910; under the age of 25 or over the age of 65; those who are neither black nor white; 
all who identify as Hispanic even if identifying as black or white; those with missing education attainment data. See papger for explanation.
 
*filter out the following for the analytic sample.
*remove respondents born prior to 1910.
FILTER OFF.
USE ALL.
SELECT IF (cohort>1909).
EXECUTE.

*remove respondents younger than 25 and older than 65.
FILTER OFF.
USE ALL.
SELECT IF (AGE > 24 & AGE < 66).
EXECUTE.

*use only black and white respondents.
FILTER OFF.
USE ALL.
SELECT IF (Race < 3).
EXECUTE.

*filter out those who are Hispanic as identified through the proxy.
*create hispanic proxy from ethnic variable.
RECODE
ethnic
(17=1) (22=1) (25=1) (38=1) (ELSE=0) INTO hispanic_proxy.
execute.

FILTER OFF.
USE ALL.
SELECT IF (hispanic_proxy =0).
EXECUTE.

*recode Hispanic var and filter out those who identify as Hispanic.
recode
hispanic
(2 thru 50=0) (0 thru 1=1) (98 thru 99=1) into nothispanic.
execute. 

FILTER OFF.
USE ALL.
SELECT IF (nothispanic=1).
EXECUTE.

*recode of respondent education attainment to remove missing data.
recode
educ
(98 thru 99 = sysmis) (else=copy) into educ_r.
execute.



*Variable recodes.

*father occupation.
compute paocc = 999.
if (year<=1987) paocc = papres16.
if (year>=1988) paocc = papres80.
execute.
freq
paocc.

*family structure recode into living with single mother.
recode
family16
(5=1) (sysmis=sysmis) (-1=sysmis) ( 9=sysmis) (else=0) into snglmother.
execute.
value labels
snglmother
1 'Single Mother'
0 'Else'.

*number of siblings.
recode
sibs
(-1=sysmis) (98 thru 99=sysmis) (else=copy) into sibs_r.
execute.
freq
sibs_r.

*perceived family income at age 16.
recode
incom16
(-1=sysmis) (7=sysmis) (8 thru 9=sysmis) (1=0) (2=1) (3=2) (4=3) (5=4) into incom16_r.
execute.
value labels
incom16_r
0 'Far below ave'
1 'below ave'
2 'ave'
3 'above ave'
4 'far above ave'.
freq
incom16_r.

*race dummy variables for black and white respondents.
recode
race
(2=1) (else=0) into black.
execute.
value labels
black
1 'Black'
0 'else'.

recode
race
(1=1) (else=0) into white.
execute.
value labels
white
1 'White'
0 'else'.

*sex dummy for male respondents.
recode
sex
(1=1) (else=0) into male.
execute.

*racegender categories used to filter t tests for table 2.
compute whitemen=0.
if (male=1) and (white=1) whitemen=1.
if (race=3) whitemale=9.
execute.
value labels
whitemale
1 'White men'
0 'else'.

compute whitewomen=0.
if (male=0) and (white=1) whitewomen=1.
if (race=3) whitewomen=9.
execute.
value labels
whitewomen
1 'White women'
0 'else'.

compute blackwomen=0.
if (male=0) and (black=1) blackwomen=1.
if (race=3) blackwomen=9.
execute.
value labels
blackwomen
1 'black women'
0 'else'.

compute blackmen=0.
if (male=1) and (black=1) blackmen=1.
if (race=3) blackmen=9.
execute.
value labels
blackmen
1 'black men'
0 'else'.

compute racegen = 99.
if (blackmen=1) racegen=1.
if (blackwomen=1) racegen=2.
if (whitemen=1) racegen=3.
if (whitewomen=1) racegen=4.
execute.
value labels
racegen
1 'black men'
2 'black women'
3 'white men'
4 'white women'.

*highest year of education attained by either parent.
compute parentedyrs = 999.
if ((paeduc<>97) and (paeduc<> 98) and (paeduc<>99)) and ((maeduc<>97) and (maeduc<> 98) and (maeduc<>99)) and (paeduc >= maeduc) parentedyrs = paeduc.
if ((paeduc<>97) and (paeduc<> 98) and (paeduc<>99)) and ((maeduc<>97) and (maeduc<> 98) and (maeduc<>99)) and (paeduc<maeduc) parentedyrs = maeduc.
if ((maeduc=97) or (maeduc=98) or (maeduc=99)) and ((paeduc<>97) or (paeduc<> 98) or (paeduc<>99)) parentedyrs = paeduc.
if ((paeduc=97) or (paeduc=98) or (paeduc=99)) and ((maeduc<>97) or (maeduc<> 98) or (maeduc<>99)) parentedyrs = maeduc.
if ((paeduc=97) or (paeduc=98) or (paeduc=99)) and ((maeduc=97) or (maeduc= 98) or (maeduc=99)) parentedyrs = 998.
execute.

recode
parentedyrs
(998=sysmis) (else=copy) into parentedyrs.
execute.


*interaction terms for regressions.
compute decadest2 = decadest*decadest.
compute black_decadest = black*decadest.
compute black_decadest2 = black*decadest2.
compute parentedyrs_decadest = parentedyrs*decadest.
compute parentedyrs_decadest2 = parentedyrs*decadest2.
compute parentedyrs_black_decadest = parentedyrs*black*decadest.
compute parentedyrs_black_decadest2 = parentedyrs*black*decadest2.
compute male_decadest = male*decadest.
compute male_decadest2 = male*decadest2.
compute parentedyrs_male_decadest = parentedyrs*male*decadest.
compute parentedyrs_male_decadest2 = parentedyrs*male*decadest2.
compute black_male_decadest = black*male*decadest.
compute black_male_decadest2 = black*male*decadest2.
compute parentedyrs_black_male_decadest = parentedyrs*black*male*decadest.
compute parentedyrs_black_male_decadest2 = parentedyrs*black*male*decadest2.
compute black_male = black*male.
compute parentedyrs_black = parentedyrs*black.
compute parentedyrs_male = parentedyrs*male.
compute parentedyrs_black_male = parentedyrs*black*male.
execute.


*logit recodes.
recode
degree
(0=3) (1 thru 2=2) (3 thru 4=1) (8=4) (else=sysmis) into edtraj.
execute.
value labels
edtraj
1 'Bachelors'
2 'HS/CC'
3 '< H.S.'
4 'DK'.

*outcome variable for tercile analysis of bachelor completion conditional on high medium and low parental ed (see appendix table 2).
recode
edtraj
(1=1) (else=0) into BAattain.
execute.
value labels
BAattain
1 'BA'
0 'Less than BA'.

*The following are misc variables used in earlier analysis to explore categorical mobility. These were ultimatley not used in the published version of the paper but may be helpful in future analysis. 
compute edclass2 =6.
if ((madeg=3) or (madeg=4)) and ((padeg=3) or (padeg=4)) edclass2=1.
if (edclass2<>1) and ((padeg=3) or (padeg=4)) edclass2=2.
if (edclass2<>1) and ((madeg=3) or (madeg=4)) edclass2=2.
if ((edclass2<>1) and (edclass2<>2)) and (madeg=2) edclass2=3.
if ((edclass2<>1) and (edclass2<>2)) and (padeg=2) edclass2=3.
if ((edclass2<>1) and (edclass2<>2) and (edclass2<>3)) and (padeg=1) edclass2=4.
if ((edclass2<>1) and (edclass2<>2) and (edclass2<>3)) and (madeg=1) edclass2=4.
if ((edclass2<>1) and (edclass2<>2) and (edclass2<>3) and (edclass2<>4)) and (madeg=0) edclass2=5.
if ((edclass2<>1) and (edclass2<>2) and (edclass2<>3) and (edclass2<>4)) and (padeg=0) edclass2=5.
execute.

recode
edclass2
(1 thru 2 = 1) (3=2) (4=3) (5=4) (else=copy) into edorigin2.
execute.
value labels
edorigin2
1 'Bachelors'
2 'Community College'
3 'High School'
4 '< High School'
6 'else'.

recode
edorigin2
(1=1) (2 thru 3=2) (4=3) (6=6) into edorigin.
execute.
value labels
edorigin
1 'Bachelors'
2 'HS/CC'
3 '< HS'
6 'Else'.

recode
edorigin
(1=1) (2 thru 3=0) (else=copy) into BAorigin.
execute.
value labels
BAorigin
1 'BA Origin'
0 'else'.

recode
degree
(0=3) (1 thru 2=2) (3 thru 4=1) (8=4) (else=sysmis) into edtraj.
execute.
value labels
edtraj
1 'Bachelors'
2 'HS/CC'
3 '< H.S.'
4 'DK'.

recode
degree
(0=4) (1=3) (2=2) (3 thru 4=1) (else=sysmis) into edtraj2.
execute.
value labels
edtraj2
1 'Bachelors'
2 'Junior College'
3 'High School'
4 '< High School'.




*multiple imputation.

FREQUENCIES VARIABLES=educ_r degree edorigin2 decades decades2 black black_decades black_decades2 female female_decades female_decades2 black_female black_female_decades black_female_decades2 
parentedyrs parentedyrs_decades paocc paocc_decades snglmother snglmother_decades sibs_r sibs_decades incom16_r incom16_decades
parentedyrs_black parentedyrs_black_decades parentedyrs_black_female_decades res16_r 
  /STATISTICS=STDDEV MEAN
  /HISTOGRAM
  /ORDER=ANALYSIS.

*Analyze Patterns of Missing Values.
MULTIPLE IMPUTATION  educ_r degree edorigin2 decades decades2 black black_decades black_decades2 female female_decades female_decades2 black_female black_female_decades black_female_decades2 
parentedyrs parentedyrs_decades paocc paocc_decades snglmother snglmother_decades sibs_r sibs_decades incom16_r incom16_decades
parentedyrs_black parentedyrs_black_decades parentedyrs_black_female_decades res16_r 
   /IMPUTE METHOD=NONE
   /MISSINGSUMMARIES  OVERALL VARIABLES (MAXVARS=30 MINPCTMISSING=0) PATTERNS
   /ANALYSISWEIGHT oversamp.

*Impute Missing Data Values.
DATASET DECLARE InterGenMCMC3.
DATASET DECLARE InterGenMCMCiteration3.
MULTIPLE IMPUTATION educ_r edorigin2 parentedyrs parentedyrs_decades parentedyrs_decades2 
    paocc snglmother sibs_r  incom16_r  
    parentedyrs_black parentedyrs_black_decades parentedyrs_black_decades2 
   parentedyrs_male parentedyrs_male_decades parentedyrs_male_decades2 
  parentedyrs_black_male parentedyrs_black_male_decades parentedyrs_black_male_decades2
  sibs_decades incom16_decades incom16_decades paocc_decades snglmother_decades
  /ANALYSISWEIGHT oversamp
  /IMPUTE METHOD=AUTO NIMPUTATIONS=5 MAXPCTMISSING=NONE  MAXCASEDRAWS=10000000 MAXPARAMDRAWS=100000
  /CONSTRAINTS educ_r( MIN=0 MAX=20 RND=1)
  /CONSTRAINTS parentedyrs( MIN=0.0 MAX=20.0 RND=1.0)
  /CONSTRAINTS parentedyrs_decades( MIN=0.0 MAX=160.0 RND=1.0)
  /CONSTRAINTS parentedyrs_decades2( Min =0.0 max = 1280 rnd = 1.0)
  /CONSTRAINTS paocc( MIN=0.0 MAX=100.0 RND=1.0)
  /CONSTRAINTS sibs_r( MIN=0.0 MAX=68.0 RND=1.0)
  /CONSTRAINTS incom16_r( MIN=0 MAX=4 RND=1)
  /CONSTRAINTS parentedyrs_black( MIN=0 MAX=20 RND=1)
  /CONSTRAINTS parentedyrs_black_decades( MIN=0 MAX=160 RND=1)
 /CONSTRAINTS parentedyrs_black_decades2 ( MIN=0 MAX=1280 RND=1)
  /CONSTRAINTS parentedyrs_black_male_decades( MIN=0.0 MAX=160.0 RND=1.0)
 /CONSTRAINTS parentedyrs_male (min=0 max=20 rnd=1.0)
 /CONSTRAINTS parentedyrs_male_decades ( MIN=0 MAX=160 RND=1)
 /CONSTRAINTS parentedyrs_male_decades2 ( MIN=0 MAX=1280 RND=1)
  /CONSTRAINTS parentedyrs_black_male ( MIN=0.0 MAX=20 RND=1.0)
  /CONSTRAINTS parentedyrs_black_male_decades2 ( MIN=0.0 MAX=1280 RND=1.0)
 /constraints sibs_decades (role=ind)
/constraints incom16_decades (role=ind)
/constraints paocc_decades (role=ind)
/constraints snglmother_decades (role=ind)
  /MISSINGSUMMARIES NONE 
  /IMPUTATIONSUMMARIES MODELS DESCRIPTIVES 
  /OUTFILE IMPUTATIONS=InterGenMCMC3 FCSITERATIONS=InterGenMCMCiteration3 .

*highest year of education attained for either parent was computed after imputing missing data for mother and father education separately.
compute parentedyrs = 999.
if ((paeduc<>97) and (paeduc<> 98) and (paeduc<>99)) and ((maeduc<>97) and (maeduc<> 98) and (maeduc<>99)) and (paeduc >= maeduc) parentedyrs = paeduc.
if ((paeduc<>97) and (paeduc<> 98) and (paeduc<>99)) and ((maeduc<>97) and (maeduc<> 98) and (maeduc<>99)) and (paeduc<maeduc) parentedyrs = maeduc.
if ((maeduc=97) or (maeduc=98) or (maeduc=99)) and ((paeduc<>97) or (paeduc<> 98) or (paeduc<>99)) parentedyrs = paeduc.
if ((paeduc=97) or (paeduc=98) or (paeduc=99)) and ((maeduc<>97) or (maeduc<> 98) or (maeduc<>99)) parentedyrs = maeduc.
if ((paeduc=97) or (paeduc=98) or (paeduc=99)) and ((maeduc=97) or (maeduc= 98) or (maeduc=99)) parentedyrs = 998.
execute.

recode
parentedyrs
(998=sysmis) (else=copy) into parentedyrs.
execute.

*respondent education mobility (Y) computed as difference between yrs of education and highest parental attainment.
compute parentedyrsdiff_r = educ_r - parentedyrs.
execute.

*recodes for tercile analysis.

compute parentedter = 99.
if (decadest=0) and (parentedyrs< 8) parentedter=0.
if (decadest=0) and ((parentedyrs > 7) and (parentedyrs < 10)) parentedter = 1.
if (decadest=0) and (parentedyrs > 9) parentedter = 2.
if (decadest=1) and (parentedyrs< 8) parentedter=3.
if (decadest=1) and ((parentedyrs > 7) and (parentedyrs < 12)) parentedter = 4.
if (decadest=1) and (parentedyrs > 11) parentedter = 5.
if (decadest=2) and (parentedyrs< 9) parentedter=6.
if (decadest=2) and ((parentedyrs > 8) and (parentedyrs < 12)) parentedter = 7.
if (decadest=2) and (parentedyrs > 11) parentedter = 8.
if (decadest=3) and (parentedyrs< 11) parentedter=9.
if (decadest=3) and ((parentedyrs > 10) and (parentedyrs < 13)) parentedter = 10.
if (decadest=3) and (parentedyrs > 12) parentedter = 11.
if (decadest=4) and (parentedyrs< 12) parentedter=12.
if (decadest=4) and (parentedyrs =12) parentedter = 13.
if (decadest=4) and (parentedyrs > 12) parentedter = 14.
if (decadest=5) and (parentedyrs< 12) parentedter=15.
if (decadest=5) and ((parentedyrs > 11) and (parentedyrs < 14)) parentedter = 16.
if (decadest=5) and (parentedyrs > 13) parentedter = 17.
if (decadest=6) and (parentedyrs< 13) parentedter=18.
if (decadest=6) and ((parentedyrs > 12) and (parentedyrs < 15)) parentedter = 19.
if (decadest=6) and (parentedyrs > 14) parentedter = 20.
if (decadest=7) and (parentedyrs< 13) parentedter=21.
if (decadest=7) and ((parentedyrs > 12) and (parentedyrs < 16)) parentedter = 22.
if (decadest=7) and (parentedyrs > 15) parentedter = 23.
execute.

recode
parentedter
(0=0) (3=0) (6=0) (9=0) (12=0) (15=0) (18=0) (21=0) (1=1) (4=1) (7=1) (10=1) (13=1) (16=1) (19=1) (22=1) 
(2=2) (5=2) (8=2) (11=2) (14=2) (17=2) (20=2) (23=2) into parentedter_r.
execute.
value labels
parentedter_r
0 'low'
1 'med' 
2 'high'.



*syntax for analysis and creation of tables 1-3 and appendix tables 1-2.

*make sure to apply weight for black oversample.
WEIGHT BY oversamp.

*split file so that the analysis is conducted sepaately for each imputed data set.
SORT CASES  BY Imputation_.
SPLIT FILE LAYERED BY Imputation_.


*table 1 descriptives.
DESCRIPTIVES VARIABLES= parentedyrs paocc snglmother sibs_r incom16_r black male decadest parentedyrsdiff_r
  /STATISTICS=MEAN STDDEV .

*table 2. Filters have been set up so that means comparisons can be run for each subgroup-by-cohort in the table.
*white men.
USE ALL.
COMPUTE filter_$=(racegen=3 & decadest = 0).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=(racegen=3 &  decadest = 1).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=(racegen=3 & decadest = 2).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=(racegen=3 & decadest =3).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=(racegen=3 &  decadest = 4).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=(racegen=3 &  decadest = 5).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=( racegen=3 &  decadest = 6).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=(racegen=3 & decadest = 7).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$1=(racegen=3 ).
FILTER BY filter_$1.
EXECUTE.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

*white women.
USE ALL.
COMPUTE filter_$=(  racegen=4 & decadest = 0).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=(  racegen=4 & decadest = 1).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=(  racegen=4 & decadest = 2).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=(  racegen=4 & decadest =3).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=(  racegen=4 & decadest = 4).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=(  racegen=4 & decadest = 5).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=(  racegen=4 & decadest = 6).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=(  racegen=4 & decadest = 7).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$1=(  racegen=4 ).
FILTER BY filter_$1.
EXECUTE.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

*black men.
USE ALL.
COMPUTE filter_$=(  racegen=1 & decadest = 0).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=(  racegen=1 & decadest = 1).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=(  racegen=1 & decadest = 2).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=(  racegen=1 & decadest =3).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=(  racegen=1 & decadest = 4).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=(  racegen=1 & decadest = 5).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=(  racegen=1 & decadest = 6).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=(  racegen=1 & decadest = 7).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$1=(  racegen=1 ).
FILTER BY filter_$1.
EXECUTE.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

*black women.

USE ALL.
COMPUTE filter_$=(  racegen=2 & decadest = 0).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=(  racegen=2 & decadest = 1).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=(  racegen=2 & decadest = 2).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=(  racegen=2 & decadest =3).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=(  racegen=2 & decadest = 4).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=(  racegen=2 & decadest = 5).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=(  racegen=2 & decadest = 6).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$=(  racegen=2 & decadest = 7).
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

USE ALL.
COMPUTE filter_$1=(  racegen=2 ).
FILTER BY filter_$1.
EXECUTE.
EXECUTE.
T-TEST PAIRS=educ_r WITH parentedyrs (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

*REGRESSIONS.
*note: if running immediately after generating results for table 2 then run the use all filter on line 802 to remove the filter used above.

Use all.

*Table 3 regression.
REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT parentedyrsdiff_r
  /METHOD=ENTER black male black_male
 /method=enter  parentedyrs paocc  snglmother sibs_r  incom16_r
/method = enter decadest decadest2 black_decadest black_decadest2 male_decadest male_decadest2 black_male_decadest black_male_decadest2
/METHOD=ENTER parentedyrs_decadest parentedyrs_decadest2 parentedyrs_black parentedyrs_black_decadest parentedyrs_black_decadest2 parentedyrs_male parentedyrs_male_decadest parentedyrs_male_decadest2
parentedyrs_black_male parentedyrs_black_male_decadest parentedyrs_black_male_decadest2
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS NORMPROB(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(3).


*tercile regression analysis.

*model for appendix table 1. To replicate table requires filtering data set by each tercile (low, medium, high). The requisite filters have been added. The model with the full list of variables (ie model 3 in each) were included in the appendix table.
*low tercile model.
USE ALL.
COMPUTE filter_$=(parentedter_r=0).
VARIABLE LABELS filter_$ 'parentedter_r=0 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT parentedyrsdiff_r
/METHOD=ENTER black male black_male
 /method=enter  paocc  snglmother sibs_r  incom16_r
/method = enter decadest decadest2 black_decadest black_decadest2 male_decadest male_decadest2 black_male_decadest black_male_decadest2
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS NORMPROB(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(3).

*medium tercile model.
USE ALL.
COMPUTE filter_$=(parentedter_r=1).
VARIABLE LABELS filter_$ 'parentedter_r=1 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT parentedyrsdiff_r
/METHOD=ENTER black male black_male
 /method=enter  paocc  snglmother sibs_r  incom16_r
/method = enter decadest decadest2 black_decadest black_decadest2 male_decadest male_decadest2 black_male_decadest black_male_decadest2
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS NORMPROB(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(3).

*high tercile model.
USE ALL.
COMPUTE filter_$=(parentedter_r=2).
VARIABLE LABELS filter_$ 'parentedter_r=2 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT parentedyrsdiff_r
/METHOD=ENTER black male black_male
 /method=enter  paocc  snglmother sibs_r  incom16_r
/method = enter decadest decadest2 black_decadest black_decadest2 male_decadest male_decadest2 black_male_decadest black_male_decadest2
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS NORMPROB(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(3).


*model for appendix table 2. Again, to replicate the tables requires filtering. Requisite filters have been added.
*low tercile model.
USE ALL.
COMPUTE filter_$=(parentedter_r=0).
VARIABLE LABELS filter_$ 'parentedter_r=0 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
LOGISTIC REGRESSION VARIABLES baattain
/METHOD=ENTER black male black_male
 /method=enter  paocc  snglmother sibs_r  incom16_r
/method = enter decadest decadest2 black_decadest black_decadest2 male_decadest male_decadest2 black_male_decadest black_male_decadest2
  /CLASSPLOT
  /PRINT=GOODFIT
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.5). 

*medium tercile model.
USE ALL.
COMPUTE filter_$=(parentedter_r=1).
VARIABLE LABELS filter_$ 'parentedter_r=1 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
LOGISTIC REGRESSION VARIABLES baattain
/METHOD=ENTER black male black_male
 /method=enter  paocc  snglmother sibs_r  incom16_r
/method = enter decadest decadest2 black_decadest black_decadest2 male_decadest male_decadest2 black_male_decadest black_male_decadest2
  /CLASSPLOT
  /PRINT=GOODFIT
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.5). 

*high tercile model.
USE ALL.
COMPUTE filter_$=(parentedter_r=2).
VARIABLE LABELS filter_$ 'parentedter_r=2 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.
LOGISTIC REGRESSION VARIABLES baattain
/METHOD=ENTER black male black_male
 /method=enter  paocc  snglmother sibs_r  incom16_r
/method = enter decadest decadest2 black_decadest black_decadest2 male_decadest male_decadest2 black_male_decadest black_male_decadest2
  /CLASSPLOT
  /PRINT=GOODFIT
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.5). 


