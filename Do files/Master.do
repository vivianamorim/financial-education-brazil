                     
														*MASTER*
														
										   *Financial Literacy Pilot in Brazil*
	*-------------------------------------------------------------------------------------------------------------------------*
	/*
	**
	*PURPOSE
	
	-> To disseminate financial education and empower the population to make more autonomous financial decisions, 
	the National Strategy for Financial Education (ENEF) was developed in 2010 by the Brazilian Federal Government.
	
	
	-> In 2015, ENEF developed a financial educational pilot targeting primary and middle school students. The Brazilian 
	municipalities of Joinville and Manaus volunteered to participate and the intervention was implemented on a sample 
	of k-9 public schools under the management of the respective municipal governments. 
	
	
	-> 	201 schools are included in the financial literacy pilot and we use stratified random sampling to assign 
	101 schools to the program and 100 schools to serve as controls. 
	
	
	-> To account for differences in both municipalities' socio-economics  standards, and schools' infrastructure, we 
	stratify the sample by the municipality and three school types: schools that 
	only offer first to fifth grades, schools that only offer sixth to ninth grades, and schools that offer all nine grades, 
	totaling six strata.
	
	
	->	ENEF created four financial education textbooks for primary and middle school students. The first one for first to 
	fourth-graders, the second one for fifth and sixth-graders, the third one for seventh and eighth-graders, and the 
	fourth one for ninth-graders. Each textbook was tailored to be adequate to students' age groups and grades. 
	The teaching material emphasizes the role of financial education in students’ everyday life by developing financial 
	concepts, such as savings, expenses, consumption, waste, and financial planning and responsibility. 
	

	-> We investigate whether providing financial literacy education to primary and middle school students improves their 
	financial knowledge and helps them to become more forward-looking decision-makers. We use a randomized control trial 
	to test a pilot implemented in Brazilian public schools in 2015. We find evidence that the intervention increased the 
	financial knowledge of seven and ninth-graders by 0.10 and 0.15 of a standard deviation, respectively. Among primary 
	school students, we observe an improvement in their decision-making involving hypothetical attitudes towards savings 
	and consumption by 0.09 and 0.12 of a standard deviation, respectively. However, our results do not suggest that the 
	effects are long-lasting and reflected in children's human capital investment decisions through the increase in math 
	and reading proficiency, grade promotion, and high-school completion. 
	
	-> To assess the impact of the intervention on human capital investiment, we asked INEP (an agency under the Brazilian
	Ministry of Education) to have assess to confidential data. We could run the analysis using masked information they 
	provided us. The impacts of the pilot on indicators presented in Table 2 of the paper were run using the agency facilities
	in Brasilia/Brazil. 
	

	**
	*WRITTEN BY 
	Isabela Furtado & Vivian Amorim
	Last Updated July 2023

	*/
	*_________________________________________________________________________________________________________________________*

	
	
	* PART 0:  INSTALL PACKAGES AND STANDARDIZE SETTINGS
	*-------------------------------------------------------------------------------------------------------------------------*

	   *Install all packages that this project requires:
	   *(Note that this never updates outdated versions of already installed commands, to update commands use adoupdate)

	   local user_commands sumstats estout unique moremata ietoolkit ivreg2 mdesc ranktest ritest rsort mediation outreg2 sxpose //Fill this list will all user-written commands this project requires
	   foreach command of local user_commands {
		   cap which `command'
		   if _rc == 111 {
			   ssc install `command', replace
		   }
	   }
	   
	   *Standardize settings accross users
	   ieboilstart, version(12.1)          //Set the version number to the oldest version used by anyone in the project team
	   `r(version)'                        //This line is needed to actually set the version from the command above

	   graph set window fontface calibri
	   set varabbrev off
	*_________________________________________________________________________________________________________________________*
	   
	   
	   
	   
	* PART 1:  PREPARING FOLDER PATH GLOBALS
	*-------------------------------------------------------------------------------------------------------------------------*
	   
	   * Users
	   * -----------

	   *User Number:
	   * Isabela                 1   
	   * Caio					 2 
	   * Vivian					 3
	   * Other					 4
	   
	   *Set this value to the user currently using this file
	   global user  3

	   * Root folder globals
	   * ---------------------

	   if $user == 1 {
		   global projectfolder  	"C:\Users\isabelabf\Dropbox\WB\SP Portfolio\Fin. Lit\Fundamental"
		   global dofiles		 	"$projectfolder/Do files"	
	   }
	   
	   
	   if $user == 2 {
		   global projectfolder  	"C:\Users\wb445183\Dropbox\Fin. Lit\Fundamental"
		   global dofiles		 	"$projectfolder/Do files"	
	   }

	   if $user == 3 {
		   global projectfolder "C:\Users\Brian\OneDrive\Desktop\financial-education-brazil\reproducibility-check-AEA"
		   global dofiles    	"C:\Users\Brian\OneDrive\Desktop\financial-education-brazil\reproducibility-check-AEA\DataWork\Do files"
	   }
	   
	   if $user == 4 {
		   global projectfolder  	"" 	//INSERT THE PATH OF THE FOLDER "reproducibility-check" 
		   global dofiles		 	""	//INSERT THE PATH OF THE  do files folder inside the "reproducibility-check" 
	   }
	   

		cd 							 "$projectfolder"
		global data					 "$projectfolder/DataWork/Data"
		global dtraw			 	 "$data/1. Raw"									//Folder that contains the data collected in the field
		global dtinter			 	 "$data/2. Intermediate" 
		global dtfinal			 	 "$data/3. Final"
		global tables 				 "$projectfolder/DataWork/Output/Tables" 
		global descriptives			 "$tables/Descriptives"
		global results			     "$tables/Results"
		global figures 				 "$projectfolder/DataWork/Output/Figures" 
		
		
	   * Datasets
	   * ---------------------
	   /*
	   We have the following dataset: 
	   
		-> Fin_Lit_pooled_data_raw.csv & Fin_Lit_pooled_data_raw. 	Survey Data collected in the field in the end of 2015 school year (students information)
		
		-> Teachers's data.dta and Teachers' data_long.				Survey Data collected in the field in the end of 2015 school year (teachers information)
		
		-> Classrooms in Manaus and Joinville_2015.dta. 			List of classrooms in Manaus and Joinville in 2015 according to Education Census.
		
		-> Enrollment by school_2007-2017.dta. 						Enrollment at school level from 2007 to 2015 according to Education Census.
		
		-> School infrastructure_2014.dta.							School infrastructure in 2014 according to Education Census. 
		
		-> Treatment and Control Groups.dta.						List of treated and control schools

		-> Fin_Lit_pooled_data_clean								Final dataset to run the analysis
		*/
		
			  


	*_________________________________________________________________________________________________________________________*
		
		
	* PART 2: SET GLOBALS FOR CONSTANTS
	*-------------------------------------------------------------------------------------------------------------------------*
	   do "$dofiles/Global.do" 
	*_________________________________________________________________________________________________________________________*
	

	
	* PART 3: - RUN DOFILES CALLED BY THIS MASTER DOFILE
	*-------------------------------------------------------------------------------------------------------------------------*
	 //Tables 4, A8, A9 and A14-> Code run in INEP facilities in Brazil as we need confidential information so our public do files do not reproduce these tables.
	 //from Brazilian Ministry of Education. 
	
	 do "$dofiles\ado\iebaltab.ado"
	 do "$dofiles\ado\medeff.ado"
	 do "$dofiles\ado\medsens.ado"
	 do "$dofiles\ado\ritest.ado"

	 
	 timer on 1
	 *run "$dofiles\1_Cleaning"				//cleans data, create important variables for analysis e saves Fin_Lit_pooled_data_clean.dta in the folder DataWork\Data\3. Final.
	 run "$dofiles\2_Descriptives.do"		
	 run "$dofiles\3_Regressions.do" 		
	 timer off 1
	 timer list 1
	*_________________________________________________________________________________________________________________________*
