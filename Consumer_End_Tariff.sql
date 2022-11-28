use ppp_fy2020_2030_annex4;
SET SQL_SAFE_UPDATES = 0;
SET GLOBAL innodb_lock_wait_timeout = 120;
SET @@SESSION.sql_mode='ALLOW_INVALID_DATES';
SET SESSION sql_mode = '';
-- SET @dt_to = STR_TO_DATE(Month, '%M,%Y');
-- update units_delivered_to_discos_and_kesc
-- set Month = str_to_date(Month, '%d/%m/%Y');
-- Show warnings;
-- SET @Month = DATE_FORMAT(Month, '%Y-%m-%d');
-- Select * from units_delivered_to_discos_and_kesc
-- select DATE_FORMAT(Month, '%m-%Y')

/* DISCO WISE ENERGY TABLE */
ALTER TABLE disco_wise_energy ADD new_created_at DATETIME;
UPDATE disco_wise_energy SET new_created_at = STR_TO_DATE(Date, '%d.%m.%Y');
ALTER TABLE disco_wise_energy DROP Date, CHANGE new_created_at Date DATETIME;

-- SELECT * from units_delivered_to_discos_and_kesc;
DROP TABLE IF EXISTS FY_Disco_Wise_Energy; 
CREATE TABLE FY_Disco_Wise_Energy
(SELECT 
CASE WHEN MONTH(Date)<7 THEN YEAR(Date)
ELSE YEAR(Date)+1 END AS 'FiscalYear',DISCO,SUM(GWh) AS Sum_GWh
FROM disco_wise_energy
GROUP BY DISCO,FiscalYear);

CREATE TABLE FY_Grouped_Disco_Wise_Energy
(SELECT 
CASE WHEN MONTH(Date)<7 THEN YEAR(Date)
ELSE YEAR(Date)+1 END AS 'FiscalYear',DISCO,SUM(GWh) AS Sum_GWh
FROM disco_wise_energy
Where DISCO<>'KESC'
GROUP BY FiscalYear);

/* UNITS DELIVERED TO DISCOs and KESC TABLE */
ALTER TABLE units_delivered_to_discos_and_kesc ADD unit_delivered_temp DATETIME;
UPDATE units_delivered_to_discos_and_kesc SET unit_delivered_temp = STR_TO_DATE(Month, '%d.%m.%Y');
ALTER TABLE units_delivered_to_discos_and_kesc DROP Month, CHANGE unit_delivered_temp Month DATETIME;

ALTER TABLE units_delivered_to_discos_and_kesc ADD unit_delivered_temp_year DATETIME;
UPDATE units_delivered_to_discos_and_kesc SET unit_delivered_temp_year = STR_TO_DATE(Year, '%Y');
ALTER TABLE units_delivered_to_discos_and_kesc DROP Year, CHANGE unit_delivered_temp_year Year DATETIME;

/* ENERGY PURCHASE PRICE TABLE */

ALTER TABLE energy_purchase_price ADD Energy_Purchase_Price DECIMAL(10,4);
UPDATE energy_purchase_price SET Energy_Purchase_Price = (Fuel_Cost_Component+Variable_OM);
ALTER TABLE energy_purchase_price ADD EPP_temp_year DATETIME;
UPDATE energy_purchase_price SET EPP_temp_year = STR_TO_DATE(Date, '%d.%m.%Y');
ALTER TABLE energy_purchase_price DROP Date, CHANGE EPP_temp_year Date DATETIME;
SELECT CASE WHEN MONTH(Date) < 7 THEN YEAR(Date)
ELSE YEAR(Date)+1 END AS 'FiscalYear',Fuel_Cost_Component
FROM energy_purchase_price;

-- ALTER TABLE energy_purchase_price ADD Fiscal_Year DATETIME;
-- UPDATE energy_purchase_price SET Fiscal_Year = IF(MONTH(Date)<7,YEAR(Date),YEAR(Date)+1);

/* DISCO MAX DEMAND TABLE */

ALTER TABLE disco_max_demand ADD MW_temp_year DATETIME;
UPDATE disco_max_demand SET MW_temp_year = STR_TO_DATE(Date, '%d.%m.%Y');
ALTER TABLE disco_max_demand DROP Date, CHANGE MW_temp_year Date DATETIME;
DROP TABLE IF EXISTS FY_Disco_Max_Demand;
CREATE TABLE FY_Disco_Max_Demand (SELECT CASE WHEN MONTH(Date) < 7 THEN YEAR(Date)
ELSE YEAR(Date)+1 END AS 'FiscalYear',DISCO,MW
FROM disco_max_demand);

DROP TABLE IF EXISTS AVG_OF_FY_MAX_DEMAND;
CREATE TABLE AVG_OF_FY_MAX_DEMAND(Select FiscalYear,DISCO,avg(nullif(MW,0)) AS Sum_of_AvgMW  from fy_disco_max_demand GROUP BY DISCO,FiscalYear);

SELECT FiscalYear,Sum(Sum_of_AvgMW) FROM AVG_OF_FY_MAX_DEMAND where FiscalYear=2020 GROUP BY FiscalYear;

SELECT 
	disco_wise_energy.Date,
    disco_max_demand.DISCO,
    CASE WHEN MONTH(disco_wise_energy.Date) IN (1,3,5,7,8,10,12) THEN ((GWh*1000)/(MW*744))
    ELSE ((GWh*1000)/(MW*720)) END AS Load_Factor
FROM disco_wise_energy
	LEFT JOIN disco_max_demand 
			ON disco_wise_energy.Date=disco_max_demand.Date
			AND disco_max_demand.DISCO=disco_wise_energy.DISCO;

/* ENERGY FUEL COMPONENT TABLE */
            
ALTER TABLE energy_fuel_component ADD fcc_temp_year DATETIME;
UPDATE energy_fuel_component SET fcc_temp_year = STR_TO_DATE(Date, '%d.%m.%Y');
ALTER TABLE energy_fuel_component DROP Date, CHANGE fcc_temp_year Date DATETIME;
SELECT CASE WHEN MONTH(Date) < 7 THEN YEAR(Date)
ELSE YEAR(Date)+1 END AS 'FiscalYear',DISCO,SUM(FCC)
FROM energy_fuel_component
GROUP BY FiscalYear,DISCO;

/* ENERGY O&M COMPONENT TABLE */

ALTER TABLE energy_om_component ADD vom_temp_year DATETIME;
UPDATE energy_om_component SET vom_temp_year = STR_TO_DATE(Date, '%d.%m.%Y');
ALTER TABLE energy_om_component DROP Date, CHANGE vom_temp_year Date DATETIME;
SELECT CASE WHEN MONTH(Date) < 7 THEN YEAR(Date)
ELSE YEAR(Date)+1 END AS 'FiscalYear',DISCO,SUM(Variable_OM)
FROM energy_om_component
GROUP BY FiscalYear,DISCO;

/* CAPCITY PURCHASE PRICE TABLE */

ALTER TABLE capacity_purchase_price ADD cpp_temp_year DATETIME;
UPDATE capacity_purchase_price SET cpp_temp_year = STR_TO_DATE(Date, '%d.%m.%Y');
ALTER TABLE capacity_purchase_price DROP Date, CHANGE cpp_temp_year Date DATETIME;
SELECT CASE WHEN MONTH(Date) < 7 THEN YEAR(Date)
ELSE YEAR(Date)+1 END AS 'FiscalYear',DISCO,SUM(CPP)
FROM capacity_purchase_price
GROUP BY FiscalYear,DISCO;

DROP TABLE IF EXISTS FY_CPP_MlnRs; 
CREATE TABLE FY_CPP_MlnRs
(SELECT 
CASE WHEN MONTH(Date)<7 THEN YEAR(Date)
ELSE YEAR(Date)+1 END AS 'FiscalYear',SUM(Capacity_Purchase_Price_MlnRs) AS Sum_CPP_MlnRs
FROM capacity_purchase_price_mlnrs
GROUP BY FiscalYear
);

/* UoSC and MOF TABLE */

ALTER TABLE uosc_and_mof ADD mof_temp_year DATETIME;
UPDATE uosc_and_mof SET mof_temp_year = STR_TO_DATE(Date, '%d.%m.%Y');
ALTER TABLE uosc_and_mof DROP Date, CHANGE mof_temp_year Date DATETIME;
SELECT CASE WHEN MONTH(Date) < 7 THEN YEAR(Date)
ELSE YEAR(Date)+1 END AS 'FiscalYear',DISCO,SUM(UoSC_and_MOF)
FROM uosc_and_mof
GROUP BY FiscalYear,DISCO;


/* POWER PURCHASE PRICE TABLE */
DROP TABLE IF EXISTS Power_Purchase_Price;
CREATE TABLE Power_Purchase_Price (Date DATE, DISCO VARCHAR(255), Power_Purchase_Price DECIMAL(10,4));

INSERT INTO Power_Purchase_Price(Date, DISCO,Power_Purchase_Price) SELECT (energy_fuel_component.Date),(energy_fuel_component.DISCO),(energy_fuel_component.FCC+energy_om_component.Variable_OM+capacity_purchase_price.CPP+uosc_and_mof.UoSC_and_MOF)
FROM energy_fuel_component
	LEFT JOIN energy_om_component 
			ON energy_fuel_component.Date=energy_om_component.Date 
            AND energy_fuel_component.DISCO=energy_om_component.DISCO
	LEFT JOIN capacity_purchase_price 
			ON energy_om_component.Date=capacity_purchase_price.Date 
            AND energy_om_component.DISCO=capacity_purchase_price.DISCO
	LEFT JOIN uosc_and_mof 
			ON capacity_purchase_price.Date=uosc_and_mof.Date 
			AND capacity_purchase_price.DISCO=uosc_and_mof.DISCO;

SELECT * from power_purchase_price;

/* ENERGY FUEL COMPONENT MLN Rs TABLE */

ALTER TABLE energy_fuel_charges_mlnrs ADD en_temp_year DATETIME;
UPDATE energy_fuel_charges_mlnrs SET en_temp_year = STR_TO_DATE(Date, '%d.%m.%Y');
ALTER TABLE energy_fuel_charges_mlnrs DROP Date, CHANGE en_temp_year Date DATETIME;
SELECT CASE WHEN MONTH(Date) < 7 THEN YEAR(Date)
ELSE YEAR(Date)+1 END AS 'FiscalYear',DISCO,SUM(Energy_Fuel_Charges_MlnRs)
FROM energy_fuel_charges_mlnrs
GROUP BY FiscalYear,DISCO;

/* ENERGY O&M COMPONENT MLN Rs TABLE */

ALTER TABLE energy_om_charges_mlnrs ADD enom_temp_year DATETIME;
UPDATE energy_om_charges_mlnrs SET enom_temp_year = STR_TO_DATE(Date, '%d.%m.%Y');
ALTER TABLE energy_om_charges_mlnrs DROP Date, CHANGE enom_temp_year Date DATETIME;
SELECT CASE WHEN MONTH(Date) < 7 THEN YEAR(Date)
ELSE YEAR(Date)+1 END AS 'FiscalYear',DISCO,SUM(Energy_OM_Charges_MlnRs)
FROM energy_om_charges_mlnrs
GROUP BY FiscalYear,DISCO;


/* CAPACITY PURCHASE PRICE MLN Rs TABLE */

ALTER TABLE capacity_purchase_price_mlnrs ADD cppmln_temp_year DATETIME;
UPDATE capacity_purchase_price_mlnrs SET cppmln_temp_year = STR_TO_DATE(Date, '%d.%m.%Y');
ALTER TABLE capacity_purchase_price_mlnrs DROP Date, CHANGE cppmln_temp_year Date DATETIME;
SELECT CASE WHEN MONTH(Date) < 7 THEN YEAR(Date)
ELSE YEAR(Date)+1 END AS 'FiscalYear',DISCO,SUM(Capacity_Purchase_Price_MlnRs)
FROM capacity_purchase_price_mlnrs
GROUP BY FiscalYear,DISCO;

DROP TABLE IF EXISTS FY_CPP_exclKE_MlnRs; 
CREATE TABLE FY_CPP_exclKE_MlnRs
(SELECT 
CASE WHEN MONTH(Date)<7 THEN YEAR(Date)
ELSE YEAR(Date)+1 END AS 'FiscalYear',SUM(Capacity_Purchase_Price_MlnRs) AS Sum_CPP_MlnRs
FROM capacity_purchase_price_mlnrs
where DISCO<>'KESC'
GROUP BY FiscalYear
);

Select FiscalYear,Sum_CPP_MlnRs from FY_CPP_exclKE_MlnRs;
/* UoSC and MOF MLN Rs TABLE */

ALTER TABLE uosc_and_mof_mlnrs ADD uoscmln_temp_year DATETIME;
UPDATE uosc_and_mof_mlnrs SET uoscmln_temp_year = STR_TO_DATE(Date, '%d.%m.%Y');
ALTER TABLE uosc_and_mof_mlnrs DROP Date, CHANGE uoscmln_temp_year Date DATETIME;
SELECT CASE WHEN MONTH(Date) < 7 THEN YEAR(Date)
ELSE YEAR(Date)+1 END AS 'FiscalYear',DISCO,SUM(UoSC_and_MOF_MlnRs)
FROM uosc_and_mof_mlnrs
GROUP BY FiscalYear,DISCO;

DROP TABLE IF EXISTS FY_UoSC_MoF_withoutKE_MlnRs; 
CREATE TABLE FY_UoSC_MoF_withoutKE_MlnRs
(SELECT 
CASE WHEN MONTH(Date)<7 THEN YEAR(Date)
ELSE YEAR(Date)+1 END AS 'FiscalYear',SUM(UoSC_and_MOF_MlnRs) AS UoSC_MoF_withoutKE_MlnRs
FROM uosc_and_mof_mlnrs
where DISCO<>'KESC'
GROUP BY FiscalYear
);

DROP TABLE IF EXISTS FY_UoSC_MoF_KEonly_MlnRs; 
CREATE TABLE FY_UoSC_MoF_KEonly_MlnRs
(SELECT 
CASE WHEN MONTH(Date)<7 THEN YEAR(Date)
ELSE YEAR(Date)+1 END AS 'FiscalYear',SUM(UoSC_and_MOF_MlnRs) AS UoSC_MoF_KEonly_MlnRs
FROM uosc_and_mof_mlnrs
where DISCO ='KESC'
GROUP BY FiscalYear
);

SELECT * FROM FY_UoSC_MoF_withoutKE_MlnRs;
Select * from FY_UoSC_MoF_KEonly_MlnRs;

SELECT POW(10,9);

DROP TABLE IF EXISTS power_purchase_price_mlnrs;
CREATE TABLE power_purchase_price_mlnrs (Date DATE, DISCO VARCHAR(255), Power_Purchase_Price_MlnRs DECIMAL(10,4));

INSERT INTO power_purchase_price_mlnrs(Date, DISCO,Power_Purchase_Price_MlnRs) SELECT (energy_fuel_charges_mlnrs.Date),(energy_fuel_charges_mlnrs.DISCO),(energy_fuel_charges_mlnrs.Energy_Fuel_Charges_MlnRs+energy_om_charges_mlnrs.Energy_OM_Charges_MlnRs+capacity_purchase_price_mlnrs.Capacity_Purchase_Price_MlnRs+uosc_and_mof_mlnrs.UoSC_and_MOF_MlnRs)
FROM energy_fuel_charges_mlnrs
	LEFT JOIN energy_om_charges_mlnrs 
			ON energy_fuel_charges_mlnrs.Date=energy_om_charges_mlnrs.Date 
            AND energy_fuel_charges_mlnrs.DISCO=energy_om_charges_mlnrs.DISCO
	LEFT JOIN capacity_purchase_price_mlnrs
			ON energy_om_charges_mlnrs.Date=capacity_purchase_price_mlnrs.Date 
            AND energy_om_charges_mlnrs.DISCO=capacity_purchase_price_mlnrs.DISCO
	LEFT JOIN uosc_and_mof_mlnrs
			ON capacity_purchase_price_mlnrs.Date=uosc_and_mof_mlnrs.Date 
			AND capacity_purchase_price_mlnrs.DISCO=uosc_and_mof_mlnrs.DISCO;

SELECT * from power_purchase_price_mlnrs;

/* Power Purchase Price MLN Rs TABLE */

SELECT CASE WHEN MONTH(Date) < 7 THEN YEAR(Date)
ELSE YEAR(Date)+1 END AS 'FiscalYear',DISCO,SUM(Power_Purchase_Price_MlnRs)
FROM power_purchase_price_mlnrs
GROUP BY FiscalYear,DISCO;

/* Economic Parameters Assumption TABLE */
use general_assumptions;
ALTER TABLE economic_parameters_assumptions ADD econ_temp_year DATETIME;
UPDATE economic_parameters_assumptions SET econ_temp_year = STR_TO_DATE(Year, '%Y');
ALTER TABLE economic_parameters_assumptions DROP Year, CHANGE econ_temp_year Year DATETIME;
SELECT * from economic_parameters_assumptions;


ALTER TABLE ntdcl_losses_forecast ADD ntl_temp_year DATETIME;
UPDATE ntdcl_losses_forecast SET ntl_temp_year = STR_TO_DATE(Year, '%Y');
ALTER TABLE ntdcl_losses_forecast DROP Year, CHANGE ntl_temp_year Year DATETIME;
SELECT * from ntdcl_losses_forecast;


ALTER TABLE ntdcl_losses_forecast_monthly ADD ntlmon_temp_year DATETIME;
UPDATE ntdcl_losses_forecast_monthly SET ntlmon_temp_year = STR_TO_DATE(Month, '%d.%m.%Y');
ALTER TABLE ntdcl_losses_forecast_monthly DROP Month, CHANGE ntlmon_temp_year Month DATETIME;
SELECT * from ntdcl_losses_forecast_monthly;


ALTER TABLE pak_cpi_for_dm ADD pkcpi_temp_year DATETIME;
UPDATE pak_cpi_for_dm SET pkcpi_temp_year = STR_TO_DATE(Year, '%Y');
ALTER TABLE pak_cpi_for_dm DROP Year, CHANGE pkcpi_temp_year Year DATETIME;
ALTER TABLE pak_cpi_for_dm MODIFY Year varchar(255);
UPDATE pak_cpi_for_dm SET Year=date_format(Year,'%Y');
SELECT * from general_assumptions.pak_cpi_for_dm;

use discos_revenue_requirement;
-- SELECT DISCOs,Parameter,Value,(SELECT SUM(Value) FROM discos_revenue_requirements WHERE Parameter IN('Energy Charge','Capacity Charge','Transmission Charge')) AS PPP_BlnRs
-- FROM discos_revenue_requirements;


/*SELECT MyTable_A.DISCOs as DISCOs, 'PPP' AS Parameter, (A_Val + B_Val) AS Value FROM 
       (SELECT DISCOs,Parameter, Value AS A_Val FROM discos_revenue_requirements WHERE Parameter='Energy Charge') AS MyTable_A
  INNER JOIN (SELECT DISCOs,Parameter, Value AS B_Val FROM discos_revenue_requirements WHERE Parameter='Capapcity Charge') AS MyTable_B
		ON  MyTable_A.DISCOs = MyTable_B.DISCOs AND
		    MyTable_A.Parameter = MyTable_B.Parameter;
  /*INNER JOIN (SELECT DISCOs,Parameter, Value AS C_Val FROM discos_revenue_requirements WHERE Parameter='Transmission Charge') AS MyTable_C
		ON MyTable_B.DISCOs = MyTable_C.DISCOs AND 
        MyTable_B.Parameter = MyTable_C.Parameter;*/
SELECT * from discos_revenue_requirements;

Insert into discos_revenue_requirements (DISCOs,Parameter,Value) 
select (DISCOs),('PPP BlnRs'),(sum(Value)) from discos_revenue_requirements where Parameter IN('Energy Charge','Capacity Charge','Transmission Charge') GROUP BY DISCOs;
Insert into discos_revenue_requirements (DISCOs,Parameter,Value) 
select (DISCOs),('Distribution Margin'),(sum(Value)) from discos_revenue_requirements where Parameter IN('O&M Cost','Depreciation','RORB','O.Income') GROUP BY DISCOs;
Insert into discos_revenue_requirements (DISCOs,Parameter,Value) 
select (DISCOs),('Prior Year Adjustment'),(sum(Value)) from discos_revenue_requirements where Parameter IN('DM_FY 18','DM_FY 17','DM_FY 16') GROUP BY DISCOs;
Insert into discos_revenue_requirements (DISCOs,Parameter,Value) 
select (DISCOs),('Write-off (For Bad Debts)'),(0) from discos_revenue_requirements GROUP BY DISCOs;
Insert into discos_revenue_requirements (DISCOs,Parameter,Value) 
select (DISCOs),('Revenue Requirement'),(sum(Value)) from discos_revenue_requirements where Parameter IN('Distribution Margin','PPP BlnRs','Prior Year Adjustment') GROUP BY DISCOs;

Insert into discos_revenue_requirements (DISCOs,Parameter,Value) 
select (DISCOs),('DM as % of CPP'),(0) from discos_revenue_requirements GROUP BY DISCOs;
UPDATE discos_revenue_requirements t1 JOIN
       discos_revenue_requirements t1_1
       ON t1_1.DISCOs=t1.DISCOs AND
       t1_1.Parameter = 'Distribution Margin' JOIN
       discos_revenue_requirements t1_2
       ON t1_2.DISCOs=t1_1.DISCOs AND
       t1_2.Parameter = 'Capacity Charge' 
    SET t1.Value = t1_1.Value / t1_2.Value 
    WHERE t1.Parameter = 'DM as % of CPP';

Insert into discos_revenue_requirements (DISCOs,Parameter,Value) 
select (DISCOs),('PPP Rs/kWh'),(0) from discos_revenue_requirements GROUP BY DISCOs;
UPDATE discos_revenue_requirements t1 JOIN
       discos_revenue_requirements t1_1
       ON t1_1.DISCOs=t1.DISCOs AND
       t1_1.Parameter = 'PPP BlnRs' JOIN
       discos_revenue_requirements t1_2
       ON t1_2.DISCOs=t1_1.DISCOs AND
       t1_2.Parameter = 'Units Sold' 
    SET t1.Value = t1_1.Value / t1_2.Value 
    WHERE t1.Parameter = 'PPP Rs/kWh';

Insert into discos_revenue_requirements (DISCOs,Parameter,Value) 
select (DISCOs),('Distribution Margin Rs/kWh'),(0) from discos_revenue_requirements GROUP BY DISCOs;
UPDATE discos_revenue_requirements t1 JOIN
       discos_revenue_requirements t1_1
       ON t1_1.DISCOs=t1.DISCOs AND
       t1_1.Parameter = 'Distribution Margin' JOIN
       discos_revenue_requirements t1_2
       ON t1_2.DISCOs=t1_1.DISCOs AND
       t1_2.Parameter = 'Units Sold' 
    SET t1.Value = t1_1.Value / t1_2.Value 
    WHERE t1.Parameter = 'Distribution Margin Rs/kWh';

Insert into discos_revenue_requirements (DISCOs,Parameter,Value) 
select (DISCOs),('PYA Rs/kWh'),(0) from discos_revenue_requirements GROUP BY DISCOs;
UPDATE discos_revenue_requirements t1 JOIN
       discos_revenue_requirements t1_1
       ON t1_1.DISCOs=t1.DISCOs AND
       t1_1.Parameter = 'Prior Year Adjustment' JOIN
       discos_revenue_requirements t1_2
       ON t1_2.DISCOs=t1_1.DISCOs AND
       t1_2.Parameter = 'Units Sold' 
    SET t1.Value = t1_1.Value / t1_2.Value 
    WHERE t1.Parameter = 'PYA Rs/kWh';

Insert into discos_revenue_requirements (DISCOs,Parameter,Value) 
select (DISCOs),('Write-Off(For Bad Debts) Rs/kWh'),(0) from discos_revenue_requirements GROUP BY DISCOs;
UPDATE discos_revenue_requirements t1 JOIN
       discos_revenue_requirements t1_1
       ON t1_1.DISCOs=t1.DISCOs AND
       t1_1.Parameter = 'Write-off (For Bad Debts)' JOIN
       discos_revenue_requirements t1_2
       ON t1_2.DISCOs=t1_1.DISCOs AND
       t1_2.Parameter = 'Units Sold' 
    SET t1.Value = t1_1.Value / t1_2.Value 
    WHERE t1.Parameter = 'Write-Off(For Bad Debts) Rs/kWh';

Insert into discos_revenue_requirements (DISCOs,Parameter,Value) 
select (DISCOs),('Avergae Tariff Rs/kWh'),(0) from discos_revenue_requirements GROUP BY DISCOs;
UPDATE discos_revenue_requirements t1 JOIN
       discos_revenue_requirements t1_1
       ON t1_1.DISCOs=t1.DISCOs AND
       t1_1.Parameter = 'Revenue Requirement' JOIN
       discos_revenue_requirements t1_2
       ON t1_2.DISCOs=t1_1.DISCOs AND
       t1_2.Parameter = 'Units Sold' 
    SET t1.Value = t1_1.Value / t1_2.Value 
    WHERE t1.Parameter = 'Avergae Tariff Rs/kWh';

Insert into discos_revenue_requirements (DISCOs,Parameter,Value) 
select (DISCOs),('PPP(FY 2015-16) Rs/kWh'),(sum(Value)) from discos_revenue_requirements where Parameter IN('Power Purchase Price FY 2015-16','Distribution Margin FY 2015-16','PYA Adjustments FY 2015-16','Write Off FY 2015-16') GROUP BY DISCOs;

Insert into discos_revenue_requirements (DISCOs,Parameter,Value) 
select (DISCOs),('Variable Revenue'),(0) from discos_revenue_requirements GROUP BY DISCOs;
UPDATE discos_revenue_requirements t1 JOIN
       discos_revenue_requirements t1_1
       ON t1_1.DISCOs=t1.DISCOs AND
       t1_1.Parameter = 'Revenue Requirement' JOIN
       discos_revenue_requirements t1_2
       ON t1_2.DISCOs=t1_1.DISCOs AND
       t1_2.Parameter = 'Fixed_Revenue' 
    SET t1.Value = t1_1.Value - t1_2.Value 
    WHERE t1.Parameter = 'Variable Revenue';

Insert into discos_revenue_requirements (DISCOs,Parameter,Value) 
select (DISCOs),('Fixed rate'),(0) from discos_revenue_requirements GROUP BY DISCOs;
UPDATE discos_revenue_requirements t1 JOIN
       discos_revenue_requirements t1_1
       ON t1_1.DISCOs=t1.DISCOs AND
       t1_1.Parameter = 'Fixed_Revenue' JOIN
       discos_revenue_requirements t1_2
       ON t1_2.DISCOs=t1_1.DISCOs AND
       t1_2.Parameter = 'Units Sold' 
    SET t1.Value = t1_1.Value / t1_2.Value 
    WHERE t1.Parameter = 'Fixed Rate';

Insert into discos_revenue_requirements (DISCOs,Parameter,Value) 
select (DISCOs),('Variable rate'),(0) from discos_revenue_requirements GROUP BY DISCOs;
UPDATE discos_revenue_requirements t1 JOIN
       discos_revenue_requirements t1_1
       ON t1_1.DISCOs=t1.DISCOs AND
       t1_1.Parameter = 'Variable Revenue' JOIN
       discos_revenue_requirements t1_2
       ON t1_2.DISCOs=t1_1.DISCOs AND
       t1_2.Parameter = 'Units Sold' 
    SET t1.Value = t1_1.Value / t1_2.Value 
    WHERE t1.Parameter = 'Variable Rate';

Insert into discos_revenue_requirements (DISCOs,Parameter,Value) 
select (DISCOs),('Avg Adjustment Rate Rs/kWh'),(0) from discos_revenue_requirements GROUP BY DISCOs;
UPDATE discos_revenue_requirements t1 JOIN
       discos_revenue_requirements t1_1
       ON t1_1.DISCOs=t1.DISCOs AND
       t1_1.Parameter = 'DM_FY 18' JOIN
       discos_revenue_requirements t1_2
       ON t1_2.DISCOs=t1_1.DISCOs AND
       t1_2.Parameter = 'Units Sold' 
    SET t1.Value = t1_1.Value / t1_2.Value 
    WHERE t1.Parameter = 'Avg Adjustment Rate Rs/kWh';



SET SQL_SAFE_UPDATES=0;
USE input_and_assumptions_for_cem;
DROP TABLE IF EXISTS input_and_assumptions_for_cem.Distribution_Margin_BlnRs;
CREATE TABLE input_and_assumptions_for_cem.Distribution_Margin_BlnRs (Date VARCHAR(255), DISCO VARCHAR(255), DM_BlnRs DECIMAL(10,4));

INSERT INTO input_and_assumptions_for_cem.Distribution_Margin_BlnRs(Date)   
SELECT DISTINCT CASE WHEN MONTH(Date) < 7 THEN YEAR(Date)
ELSE YEAR(Date)+1 END AS 'FiscalYear'
FROM ppp_fy2020_2030_annex4.energy_fuel_charges_mlnrs 
WHERE Date NOT IN(SELECT Date FROM input_and_assumptions_for_cem.Distribution_Margin_BlnRs);

SELECT YEAR(str_to_date(Date,"%YYYY")) FROM input_and_assumptions_for_cem.Distribution_Margin_BlnRs;

-- --------------------------------------------------------------------------- IESCO ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- INSERT INTO Distribution_Margin_BlnRs(DISCO) VALUE('IESCO');
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DISCO = 'IESCO' where Date=2020;
-- INSERT INTO Distribution_Margin_BlnRs(DM_BlnRs) (SELECT (Value/1000) FROM input_and_assumptions_for_cem.distribution_margin_mlnrs WHERE Parameter='DM Mln Rs' AND DISCOs = 'IESCO');
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT (Value/1000) FROM input_and_assumptions_for_cem.distribution_margin_millionrs WHERE Parameter='DM Million Rs' AND DISCOs = 'IESCO') WHERE Date=2020;
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT (Value/1000+1.45865) FROM input_and_assumptions_for_cem.distribution_margin_millionrs WHERE Parameter='DM Million Rs' AND DISCOs = 'IESCO') WHERE Date=2021;
UPDATE Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT * FROM (SELECT DM_BlnRs*((
																				(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=2022 AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                /(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=2021 AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB')))
                                                                                +((SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=2022)
                                                                                /(SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=2021)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('Depreciation','RORB'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB'))))
                                                                                )) FROM Distribution_Margin_BlnRs WHERE Date=2021)temTbl1) WHERE Date=2022;

										

DROP PROCEDURE IF EXISTS fillup_DM;
delimiter //
CREATE PROCEDURE fillup_DM()

BEGIN

DECLARE prev_yr INT unsigned DEFAULT 2022;
DECLARE new_yr INT unsigned DEFAULT 2023;
WHILE new_yr <= 2030 DO
    UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT * FROM (SELECT DM_BlnRs*((
																				(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=new_yr AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                /(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=prev_yr AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB')))
                                                                                +((SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=new_yr)
                                                                                /(SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=prev_yr)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('Depreciation','RORB'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB'))))
                                                                                )) FROM input_and_assumptions_for_cem.Distribution_Margin_BlnRs WHERE Date=prev_yr)temTbl1) WHERE Date=new_yr;
    SET prev_yr = prev_yr + 1;
    SET new_yr = new_yr + 1;
END WHILE;
END//

delimiter ;

CALL fillup_DM();


-- SELECT * FROM avg_of_fy_max_demand;
/*
SELECT FiscalYear,SUM(Sum_of_AvgMW) FROM avg_of_fy_max_demand WHERE FiscalYear=2020 AND DISCO<>'KESC' group by FiscalYear;
*/


DROP PROCEDURE IF EXISTS doiterate;
delimiter //
CREATE PROCEDURE doiterate()

BEGIN

DECLARE total INT unsigned DEFAULT 0;
WHILE total <= 9 DO
    UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DISCO = 'IESCO';
    SET total = total + 1;
END WHILE;
END//

delimiter ;
CALL doiterate(); 

-- ----------------------------------------------------------------------------------------- LESCO ---------------------------------------------------------------------------------------------------------------------------------
 
-- UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT (Value/1000+2.56566) FROM input_and_assumptions_for_cem.distribution_margin_millionrs WHERE Parameter='DM Million Rs' AND DISCOs = 'LESCO') WHERE Date=2021 AND 'LESCO';


DROP PROCEDURE IF EXISTS yrinsert;
delimiter //
CREATE PROCEDURE yrinsert()

BEGIN
DECLARE init INT unsigned DEFAULT 2020;


	WHILE init <= 2030 DO
		INSERT INTO input_and_assumptions_for_cem.Distribution_Margin_BlnRs(Date,DISCO) VALUE(init,'LESCO');
		SET init = init + 1;
	END WHILE;

END//
delimiter ;
CALL yrinsert();

-- UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET Date=2020 WHERE DISCO='LESCO';
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT (Value/1000) FROM input_and_assumptions_for_cem.distribution_margin_millionrs WHERE Parameter='DM Million Rs' AND DISCOs = 'LESCO') WHERE Date=2020 AND DISCO='LESCO';
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT (Value/1000+2.56566) FROM input_and_assumptions_for_cem.distribution_margin_millionrs WHERE Parameter='DM Million Rs' AND DISCOs = 'LESCO') WHERE Date=2021 AND DISCO='LESCO';
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT * FROM (SELECT DM_BlnRs*((
																				(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=2022 AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                /(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=2021 AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB')))
                                                                                +((SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=2022)
                                                                                /(SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=2021)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('Depreciation','RORB'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB'))))
                                                                                )) FROM Distribution_Margin_BlnRs WHERE Date=2021 AND DISCO='LESCO')temTbl1) WHERE Date=2022 AND DISCO='LESCO';

DROP PROCEDURE IF EXISTS fillup_DM;
delimiter //
CREATE PROCEDURE fillup_DM()

BEGIN

DECLARE prev_yr INT unsigned DEFAULT 2022;
DECLARE new_yr INT unsigned DEFAULT 2023;
WHILE new_yr <= 2030 DO
    UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT * FROM (SELECT DM_BlnRs*((
																				(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=new_yr AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                /(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=prev_yr AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB')))
                                                                                +((SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=new_yr)
                                                                                /(SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=prev_yr)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('Depreciation','RORB'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB'))))
                                                                                )) FROM input_and_assumptions_for_cem.Distribution_Margin_BlnRs WHERE Date=prev_yr and DISCO='LESCO')temTbl1) WHERE Date=new_yr AND DISCO='LESCO';
    SET prev_yr = prev_yr + 1;
    SET new_yr = new_yr + 1;
END WHILE;
END//

delimiter ;

CALL fillup_DM();
-- ----------------------------------------------------------------------------------------------------GEPCO--------------------------------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS yrinsert;
delimiter //
CREATE PROCEDURE yrinsert()

BEGIN
DECLARE init INT unsigned DEFAULT 2020;


	WHILE init <= 2030 DO
		INSERT INTO input_and_assumptions_for_cem.Distribution_Margin_BlnRs(Date,DISCO) VALUE(init,'GEPCO');
		SET init = init + 1;
	END WHILE;

END//
delimiter ;
CALL yrinsert();

-- UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET Date=2020 WHERE DISCO='LESCO';
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT (Value/1000) FROM input_and_assumptions_for_cem.distribution_margin_millionrs WHERE Parameter='DM Million Rs' AND DISCOs = 'GEPCO') WHERE Date=2020 AND DISCO='GEPCO';
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT (Value/1000+2.897868) FROM input_and_assumptions_for_cem.distribution_margin_millionrs WHERE Parameter='DM Million Rs' AND DISCOs = 'GEPCO') WHERE Date=2021 AND DISCO='GEPCO';
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT * FROM (SELECT DM_BlnRs*((
																				(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=2022 AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                /(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=2021 AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB')))
                                                                                +((SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=2022)
                                                                                /(SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=2021)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('Depreciation','RORB'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB'))))
                                                                                )) FROM Distribution_Margin_BlnRs WHERE Date=2021 AND DISCO='GEPCO')temTbl1) WHERE Date=2022 AND DISCO='GEPCO';

DROP PROCEDURE IF EXISTS fillup_DM;
delimiter //
CREATE PROCEDURE fillup_DM()

BEGIN

DECLARE prev_yr INT unsigned DEFAULT 2022;
DECLARE new_yr INT unsigned DEFAULT 2023;
WHILE new_yr <= 2030 DO
    UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT * FROM (SELECT DM_BlnRs*((
																				(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=new_yr AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                /(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=prev_yr AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB')))
                                                                                +((SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=new_yr)
                                                                                /(SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=prev_yr)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('Depreciation','RORB'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB'))))
                                                                                )) FROM input_and_assumptions_for_cem.Distribution_Margin_BlnRs WHERE Date=prev_yr and DISCO='GEPCO')temTbl1) WHERE Date=new_yr AND DISCO='GEPCO';
    SET prev_yr = prev_yr + 1;
    SET new_yr = new_yr + 1;
END WHILE;
END//

delimiter ;

CALL fillup_DM();

-- ----------------------------------------------------------------------------- FESCO -----------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS yrinsert;
delimiter //
CREATE PROCEDURE yrinsert()

BEGIN
DECLARE init INT unsigned DEFAULT 2020;


	WHILE init <= 2030 DO
		INSERT INTO input_and_assumptions_for_cem.Distribution_Margin_BlnRs(Date,DISCO) VALUE(init,'FESCO');
		SET init = init + 1;
	END WHILE;

END//
delimiter ;
CALL yrinsert();

-- UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET Date=2020 WHERE DISCO='LESCO';
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT (Value/1000) FROM input_and_assumptions_for_cem.distribution_margin_millionrs WHERE Parameter='DM Million Rs' AND DISCOs = 'FESCO') WHERE Date=2020 AND DISCO='FESCO';
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT (Value/1000+1.74789) FROM input_and_assumptions_for_cem.distribution_margin_millionrs WHERE Parameter='DM Million Rs' AND DISCOs = 'FESCO') WHERE Date=2021 AND DISCO='FESCO';
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT * FROM (SELECT DM_BlnRs*((
																				(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=2022 AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                /(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=2021 AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB')))
                                                                                +((SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=2022)
                                                                                /(SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=2021)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('Depreciation','RORB'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB'))))
                                                                                )) FROM Distribution_Margin_BlnRs WHERE Date=2021 AND DISCO='FESCO')temTbl1) WHERE Date=2022 AND DISCO='FESCO';

DROP PROCEDURE IF EXISTS fillup_DM;
delimiter //
CREATE PROCEDURE fillup_DM()

BEGIN

DECLARE prev_yr INT unsigned DEFAULT 2022;
DECLARE new_yr INT unsigned DEFAULT 2023;
WHILE new_yr <= 2030 DO
    UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT * FROM (SELECT DM_BlnRs*((
																				(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=new_yr AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                /(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=prev_yr AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB')))
                                                                                +((SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=new_yr)
                                                                                /(SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=prev_yr)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('Depreciation','RORB'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB'))))
                                                                                )) FROM input_and_assumptions_for_cem.Distribution_Margin_BlnRs WHERE Date=prev_yr and DISCO='FESCO')temTbl1) WHERE Date=new_yr AND DISCO='FESCO';
    SET prev_yr = prev_yr + 1;
    SET new_yr = new_yr + 1;
END WHILE;
END//

delimiter ;

CALL fillup_DM();


-- ----------------------------------------------------------------------------- MEPCO -----------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS yrinsert;
delimiter //
CREATE PROCEDURE yrinsert()

BEGIN
DECLARE init INT unsigned DEFAULT 2020;


	WHILE init <= 2030 DO
		INSERT INTO input_and_assumptions_for_cem.Distribution_Margin_BlnRs(Date,DISCO) VALUE(init,'MEPCO');
		SET init = init + 1;
	END WHILE;

END//
delimiter ;
CALL yrinsert();

-- UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET Date=2020 WHERE DISCO='LESCO';
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT (Value/1000) FROM input_and_assumptions_for_cem.distribution_margin_millionrs WHERE Parameter='DM Million Rs' AND DISCOs = 'MEPCO') WHERE Date=2020 AND DISCO='MEPCO';
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT (Value/1000+4.79149) FROM input_and_assumptions_for_cem.distribution_margin_millionrs WHERE Parameter='DM Million Rs' AND DISCOs = 'MEPCO') WHERE Date=2021 AND DISCO='MEPCO';
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT * FROM (SELECT DM_BlnRs*((
																				(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=2022 AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                /(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=2021 AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB')))
                                                                                +((SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=2022)
                                                                                /(SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=2021)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('Depreciation','RORB'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB'))))
                                                                                )) FROM Distribution_Margin_BlnRs WHERE Date=2021 AND DISCO='MEPCO')temTbl1) WHERE Date=2022 AND DISCO='MEPCO';

DROP PROCEDURE IF EXISTS fillup_DM;
delimiter //
CREATE PROCEDURE fillup_DM()

BEGIN

DECLARE prev_yr INT unsigned DEFAULT 2022;
DECLARE new_yr INT unsigned DEFAULT 2023;
WHILE new_yr <= 2030 DO
    UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT * FROM (SELECT DM_BlnRs*((
																				(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=new_yr AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                /(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=prev_yr AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB')))
                                                                                +((SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=new_yr)
                                                                                /(SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=prev_yr)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('Depreciation','RORB'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB'))))
                                                                                )) FROM input_and_assumptions_for_cem.Distribution_Margin_BlnRs WHERE Date=prev_yr and DISCO='MEPCO')temTbl1) WHERE Date=new_yr AND DISCO='MEPCO';
    SET prev_yr = prev_yr + 1;
    SET new_yr = new_yr + 1;
END WHILE;
END//

delimiter ;

CALL fillup_DM();


-- ----------------------------------------------------------------------------- HESCO -----------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS yrinsert;
delimiter //
CREATE PROCEDURE yrinsert()

BEGIN
DECLARE init INT unsigned DEFAULT 2020;


	WHILE init <= 2030 DO
		INSERT INTO input_and_assumptions_for_cem.Distribution_Margin_BlnRs(Date,DISCO) VALUE(init,'HESCO');
		SET init = init + 1;
	END WHILE;

END//
delimiter ;
CALL yrinsert();

-- UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET Date=2020 WHERE DISCO='LESCO';
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT (Value/1000) FROM input_and_assumptions_for_cem.distribution_margin_millionrs WHERE Parameter='DM Million Rs' AND DISCOs = 'HESCO') WHERE Date=2020 AND DISCO='HESCO';
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT (Value/1000+1.6126) FROM input_and_assumptions_for_cem.distribution_margin_millionrs WHERE Parameter='DM Million Rs' AND DISCOs = 'HESCO') WHERE Date=2021 AND DISCO='HESCO';
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT * FROM (SELECT DM_BlnRs*((
																				(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=2022 AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                /(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=2021 AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB')))
                                                                                +((SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=2022)
                                                                                /(SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=2021)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('Depreciation','RORB'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB'))))
                                                                                )) FROM Distribution_Margin_BlnRs WHERE Date=2021 AND DISCO='HESCO')temTbl1) WHERE Date=2022 AND DISCO='HESCO';

DROP PROCEDURE IF EXISTS fillup_DM;
delimiter //
CREATE PROCEDURE fillup_DM()

BEGIN

DECLARE prev_yr INT unsigned DEFAULT 2022;
DECLARE new_yr INT unsigned DEFAULT 2023;
WHILE new_yr <= 2030 DO
    UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT * FROM (SELECT DM_BlnRs*((
																				(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=new_yr AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                /(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=prev_yr AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB')))
                                                                                +((SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=new_yr)
                                                                                /(SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=prev_yr)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('Depreciation','RORB'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB'))))
                                                                                )) FROM input_and_assumptions_for_cem.Distribution_Margin_BlnRs WHERE Date=prev_yr and DISCO='HESCO')temTbl1) WHERE Date=new_yr AND DISCO='HESCO';
    SET prev_yr = prev_yr + 1;
    SET new_yr = new_yr + 1;
END WHILE;
END//

delimiter ;

CALL fillup_DM();


-- ----------------------------------------------------------------------------- QESCO -----------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS yrinsert;
delimiter //
CREATE PROCEDURE yrinsert()

BEGIN
DECLARE init INT unsigned DEFAULT 2020;


	WHILE init <= 2030 DO
		INSERT INTO input_and_assumptions_for_cem.Distribution_Margin_BlnRs(Date,DISCO) VALUE(init,'QESCO');
		SET init = init + 1;
	END WHILE;

END//
delimiter ;
CALL yrinsert();

-- UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET Date=2020 WHERE DISCO='LESCO';
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT (Value/1000) FROM input_and_assumptions_for_cem.distribution_margin_millionrs WHERE Parameter='DM Million Rs' AND DISCOs = 'QESCO') WHERE Date=2020 AND DISCO='QESCO';
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT (Value/1000+1.603379) FROM input_and_assumptions_for_cem.distribution_margin_millionrs WHERE Parameter='DM Million Rs' AND DISCOs = 'QESCO') WHERE Date=2021 AND DISCO='QESCO';
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT * FROM (SELECT DM_BlnRs*((
																				(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=2022 AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                /(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=2021 AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB')))
                                                                                +((SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=2022)
                                                                                /(SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=2021)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('Depreciation','RORB'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB'))))
                                                                                )) FROM Distribution_Margin_BlnRs WHERE Date=2021 AND DISCO='QESCO')temTbl1) WHERE Date=2022 AND DISCO='QESCO';

DROP PROCEDURE IF EXISTS fillup_DM;
delimiter //
CREATE PROCEDURE fillup_DM()

BEGIN

DECLARE prev_yr INT unsigned DEFAULT 2022;
DECLARE new_yr INT unsigned DEFAULT 2023;
WHILE new_yr <= 2030 DO
    UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT * FROM (SELECT DM_BlnRs*((
																				(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=new_yr AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                /(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=prev_yr AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB')))
                                                                                +((SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=new_yr)
                                                                                /(SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=prev_yr)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('Depreciation','RORB'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB'))))
                                                                                )) FROM input_and_assumptions_for_cem.Distribution_Margin_BlnRs WHERE Date=prev_yr and DISCO='QESCO')temTbl1) WHERE Date=new_yr AND DISCO='QESCO';
    SET prev_yr = prev_yr + 1;
    SET new_yr = new_yr + 1;
END WHILE;
END//

delimiter ;

CALL fillup_DM();


-- ----------------------------------------------------------------------------- SEPCO -----------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS yrinsert;
delimiter //
CREATE PROCEDURE yrinsert()

BEGIN
DECLARE init INT unsigned DEFAULT 2020;


	WHILE init <= 2030 DO
		INSERT INTO input_and_assumptions_for_cem.Distribution_Margin_BlnRs(Date,DISCO) VALUE(init,'SEPCO');
		SET init = init + 1;
	END WHILE;

END//
delimiter ;
CALL yrinsert();

-- UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET Date=2020 WHERE DISCO='LESCO';
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT (Value/1000) FROM input_and_assumptions_for_cem.distribution_margin_millionrs WHERE Parameter='DM Million Rs' AND DISCOs = 'SEPCO') WHERE Date=2020 AND DISCO='SEPCO';
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT (Value/1000+0.88212) FROM input_and_assumptions_for_cem.distribution_margin_millionrs WHERE Parameter='DM Million Rs' AND DISCOs = 'SEPCO') WHERE Date=2021 AND DISCO='SEPCO';
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT * FROM (SELECT DM_BlnRs*((
																				(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=2022 AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                /(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=2021 AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB')))
                                                                                +((SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=2022)
                                                                                /(SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=2021)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('Depreciation','RORB'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB'))))
                                                                                )) FROM Distribution_Margin_BlnRs WHERE Date=2021 AND DISCO='SEPCO')temTbl1) WHERE Date=2022 AND DISCO='SEPCO';

DROP PROCEDURE IF EXISTS fillup_DM;
delimiter //
CREATE PROCEDURE fillup_DM()

BEGIN

DECLARE prev_yr INT unsigned DEFAULT 2022;
DECLARE new_yr INT unsigned DEFAULT 2023;
WHILE new_yr <= 2030 DO
    UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT * FROM (SELECT DM_BlnRs*((
																				(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=new_yr AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                /(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=prev_yr AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB')))
                                                                                +((SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=new_yr)
                                                                                /(SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=prev_yr)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('Depreciation','RORB'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB'))))
                                                                                )) FROM input_and_assumptions_for_cem.Distribution_Margin_BlnRs WHERE Date=prev_yr and DISCO='SEPCO')temTbl1) WHERE Date=new_yr AND DISCO='SEPCO';
    SET prev_yr = prev_yr + 1;
    SET new_yr = new_yr + 1;
END WHILE;
END//

delimiter ;

CALL fillup_DM();


-- ----------------------------------------------------------------------------- PESCO -----------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS yrinsert;
delimiter //
CREATE PROCEDURE yrinsert()

BEGIN
DECLARE init INT unsigned DEFAULT 2020;


	WHILE init <= 2030 DO
		INSERT INTO input_and_assumptions_for_cem.Distribution_Margin_BlnRs(Date,DISCO) VALUE(init,'PESCO');
		SET init = init + 1;
	END WHILE;

END//
delimiter ;
CALL yrinsert();

-- UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET Date=2020 WHERE DISCO='LESCO';
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT (Value/1000) FROM input_and_assumptions_for_cem.distribution_margin_millionrs WHERE Parameter='DM Million Rs' AND DISCOs = 'PESCO') WHERE Date=2020 AND DISCO='PESCO';
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT (Value/1000+3.817055) FROM input_and_assumptions_for_cem.distribution_margin_millionrs WHERE Parameter='DM Million Rs' AND DISCOs = 'PESCO') WHERE Date=2021 AND DISCO='PESCO';
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT * FROM (SELECT DM_BlnRs*((
																				(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=2022 AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                /(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=2021 AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB')))
                                                                                +((SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=2022)
                                                                                /(SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=2021)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('Depreciation','RORB'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB'))))
                                                                                )) FROM Distribution_Margin_BlnRs WHERE Date=2021 AND DISCO='PESCO')temTbl1) WHERE Date=2022 AND DISCO='PESCO';

DROP PROCEDURE IF EXISTS fillup_DM;
delimiter //
CREATE PROCEDURE fillup_DM()

BEGIN

DECLARE prev_yr INT unsigned DEFAULT 2022;
DECLARE new_yr INT unsigned DEFAULT 2023;
WHILE new_yr <= 2030 DO
    UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT * FROM (SELECT DM_BlnRs*((
																				(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=new_yr AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                /(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=prev_yr AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB')))
                                                                                +((SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=new_yr)
                                                                                /(SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=prev_yr)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('Depreciation','RORB'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB'))))
                                                                                )) FROM input_and_assumptions_for_cem.Distribution_Margin_BlnRs WHERE Date=prev_yr and DISCO='PESCO')temTbl1) WHERE Date=new_yr AND DISCO='PESCO';
    SET prev_yr = prev_yr + 1;
    SET new_yr = new_yr + 1;
END WHILE;
END//

delimiter ;

CALL fillup_DM();


-- ----------------------------------------------------------------------------- TESCO -----------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS yrinsert;
delimiter //
CREATE PROCEDURE yrinsert()

BEGIN
DECLARE init INT unsigned DEFAULT 2020;


	WHILE init <= 2030 DO
		INSERT INTO input_and_assumptions_for_cem.Distribution_Margin_BlnRs(Date,DISCO) VALUE(init,'TESCO');
		SET init = init + 1;
	END WHILE;

END//
delimiter ;
CALL yrinsert();

-- UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET Date=2020 WHERE DISCO='LESCO';
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT (Value/1000) FROM input_and_assumptions_for_cem.distribution_margin_millionrs WHERE Parameter='DM Million Rs' AND DISCOs = 'TESCO') WHERE Date=2020 AND DISCO='TESCO';
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT (Value/1000-1.60439) FROM input_and_assumptions_for_cem.distribution_margin_millionrs WHERE Parameter='DM Million Rs' AND DISCOs = 'TESCO') WHERE Date=2021 AND DISCO='TESCO';
UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT * FROM (SELECT DM_BlnRs*((
																				(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=2022 AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                /(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=2021 AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB')))
                                                                                +((SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=2022)
                                                                                /(SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=2021)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('Depreciation','RORB'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB'))))
                                                                                )) FROM Distribution_Margin_BlnRs WHERE Date=2021 AND DISCO='TESCO')temTbl1) WHERE Date=2022 AND DISCO='TESCO';

DROP PROCEDURE IF EXISTS fillup_DM;
delimiter //
CREATE PROCEDURE fillup_DM()

BEGIN

DECLARE prev_yr INT unsigned DEFAULT 2022;
DECLARE new_yr INT unsigned DEFAULT 2023;
WHILE new_yr <= 2030 DO
    UPDATE input_and_assumptions_for_cem.Distribution_Margin_BlnRs SET DM_BlnRs = (SELECT * FROM (SELECT DM_BlnRs*((
																				(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=new_yr AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                /(SELECT SUM(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.avg_of_fy_max_demand WHERE FiscalYear=prev_yr AND DISCO<>'KESC' GROUP BY FiscalYear)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB')))
                                                                                +((SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=new_yr)
                                                                                /(SELECT Value FROM general_assumptions.pak_cpi_for_dm WHERE Year=prev_yr)
                                                                                *((SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('Depreciation','RORB'))
                                                                                /(SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB'))))
                                                                                )) FROM input_and_assumptions_for_cem.Distribution_Margin_BlnRs WHERE Date=prev_yr and DISCO='TESCO')temTbl1) WHERE Date=new_yr AND DISCO='TESCO';
    SET prev_yr = prev_yr + 1;
    SET new_yr = new_yr + 1;
END WHILE;
END//

delimiter ;

CALL fillup_DM();

-- ____________________________________________________________________________________________________Prior Year Adjustment (PYA)________________________________________________________________________________________________________________________________________________________________________________________________________

-- SELECT YEAR(str_to_date(Date,"%YYYY")) FROM input_and_assumptions_for_cem.PYA_BlnRs;
-- UPDATE input_and_assumptions_for_cem.PYA_BlnRs SET DISCO = 'IESCO' where Date=2020;
-- UPDATE input_and_assumptions_for_cem.PYA_BlnRs SET PYA_BlnRs = 35.260813 where Date=2020 AND DISCO='IESCO';

-- SELECT * FROM input_and_assumptions_for_cem.PYA_BlnRs;
-- SELECT * FROM input_and_assumptions_for_cem.distribution_margin_millionrs;
-- SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income');
-- SELECT SUM(Value) FROM discos_revenue_requirement.discos_revenue_requirements WHERE Parameter IN ('O&M Cost','O.Income','Depreciation','RORB');

SELECT * FROM distribution_margin_millionrs;
-- _____________________________________________________________________________________________  Total Revenue Requirements _______________________________________________________________________________________________________________________________________________________________________________________________________________________

DROP TABLE IF EXISTS input_and_assumptions_for_cem.Total_revenue_requirements;
CREATE TABLE input_and_assumptions_for_cem.Total_revenue_requirements (Date VARCHAR(255), DISCO VARCHAR(255), Total_RR_BlnRs DECIMAL(10,4));

use ppp_fy2020_2030_annex4;
DROP TABLE IF EXISTS PPP_BlnRs;
CREATE TABLE PPP_BlnRs (SELECT CASE WHEN MONTH(Date) < 7 THEN YEAR(Date)
ELSE YEAR(Date)+1 END AS 'FiscalYear',DISCO,Power_Purchase_Price_MlnRs
FROM ppp_fy2020_2030_annex4.power_purchase_price_mlnrs);

DROP TABLE IF EXISTS FY_PPP_BlnRs;
CREATE TABLE FY_PPP_BlnRs(Select FiscalYear,DISCO,sum(nullif(Power_Purchase_Price_MlnRs,0)/1000) AS PPP_BlnRs  from PPP_BlnRs GROUP BY DISCO,FiscalYear);
SELECT * FROM fy_ppp_blnrs;

-- alter table ppp_fy2020_2030_annex4.fy_ppp_blnrs change FiscalYear FiscalYear varchar(20);

use input_and_assumptions_for_cem;


INSERT INTO Total_revenue_requirements(Date, DISCO,Total_RR_BlnRs) SELECT (ppp_fy2020_2030_annex4.fy_ppp_blnrs.FiscalYear),(input_and_assumptions_for_cem.pya_blnrs.DISCO),(ppp_fy2020_2030_annex4.fy_ppp_blnrs.PPP_BlnRs+input_and_assumptions_for_cem.pya_blnrs.PYA_BlnRs+input_and_assumptions_for_cem.distribution_margin_blnrs.DM_BlnRs)
FROM ppp_fy2020_2030_annex4.fy_ppp_blnrs
	LEFT JOIN input_and_assumptions_for_cem.distribution_margin_blnrs 
			ON ppp_fy2020_2030_annex4.fy_ppp_blnrs.FiscalYear=input_and_assumptions_for_cem.distribution_margin_blnrs.Date
            AND ppp_fy2020_2030_annex4.fy_ppp_blnrs.DISCO=input_and_assumptions_for_cem.distribution_margin_blnrs.DISCO
	LEFT JOIN input_and_assumptions_for_cem.pya_blnrs 
			ON ppp_fy2020_2030_annex4.fy_ppp_blnrs.FiscalYear=input_and_assumptions_for_cem.pya_blnrs.Date 
            AND ppp_fy2020_2030_annex4.fy_ppp_blnrs.DISCO=input_and_assumptions_for_cem.pya_blnrs.DISCO;

SELECT * FROM total_revenue_requirements;
-- __________________________________________________________Category Wise Forecasted GWh Consumption (PMS Based)__________________________________________________________________________________________________________________________
use revenue_energy_inputs_for_cem;
DROP TABLE IF EXISTS FY_category_wise_forecasted_gwh_consumption_pms_based;
CREATE TABLE FY_category_wise_forecasted_gwh_consumption_pms_based(SELECT date_format(Year,"%Y") as FiscalYear,Category,GWh FROM category_wise_forecasted_gwh_consumption_pms_based);

SELECT * FROM FY_category_wise_forecasted_gwh_consumption_pms_based;

/*
SET @GWh=0;

SELECT
    m1.Fiscalyear,Category,
    CASE WHEN(((m1.GWh - @GWh)/@GWh)>1 OR ((m1.GWh - @GWh)/@GWh)<0) THEN 0 ELSE ((m1.GWh - @GWh)/@GWh) END AS pct_diff,
    @GWh := m1.GWh GWh
    -- m1.FiscalYear
FROM FY_category_wise_forecasted_gwh_consumption_pms_based m1;
*/
SET @GWh=0;
SELECT
    m1.Fiscalyear,Category,
    CASE WHEN m1.category=m1.category THEN 
    (CASE WHEN(((m1.GWh - @GWh)/@GWh)>1 OR ((m1.GWh - @GWh)/@GWh)<0) THEN 0 ELSE ((m1.GWh - @GWh)/@GWh) END) ELSE 0 END AS Pct_diff,
    @GWh := m1.GWh GWh
    -- m1.FiscalYear
FROM FY_category_wise_forecasted_gwh_consumption_pms_based m1;

SELECT
    m.FiscalYear,
    Category,
    GWh,
    GWh / t.Total * 100 AS Percentage
FROM
    FY_category_wise_forecasted_gwh_consumption_pms_based AS m
JOIN (    
    SELECT
        FiscalYear,
        SUM(GWh) AS Total
    FROM
        FY_category_wise_forecasted_gwh_consumption_pms_based
	GROUP BY
        FiscalYear) AS t ON t.FiscalYear = m.FiscalYear;
    
Drop Table If Exists Energy_mix_pctage; 
CREATE TABLE IF NOT EXISTS Energy_mix_pctage (FiscalYear VARCHAR(20),Sector VARCHAR(255),Category VARCHAR(255),Percentage DECIMAL(10,8));
INSERT INTO Energy_mix_pctage VALUES(2018,'Residential','Up to 50 Units',0.0215),
									(2018,'Residential','01-100 Units (Peak Load<5kW)',0.144),
									(2018,'Residential','101-200 Units  (Peak Load<5kW)',0.1109),
									(2018,'Residential','201-300 Units  (Peak Load<5kW)',0.0994),
									(2018,'Residential','301-700 Units  (Peak Load<5kW)',0.0552),
                                    (2018,'Residential','Above 700 Units  (Peak Load<5kW)',0.0172),
                                    (2018,'Residential','Time of Use (TOU) - Peak  (Peak Load>5kW)',0.0058),
                                    (2018,'Residential','Time of Use (TOU) - Off-Peak  (Peak Load>5kW)',0.0271),
                                    (2018,'Residential','Temporary Supply',0.0000427),
                                    (2018,'Commercial - A2','Peak Load<5kW',0.0275),
                                    (2018,'Commercial - A2','Regular  (Peak Load>5kW)',0.001),
									(2018,'Commercial - A2','Time of Use (TOU) - Peak  (Peak Load>5kW)',0.0079),
                                    (2018,'Commercial - A2','Time of Use (TOU) - Off-Peak  (Peak Load>5kW)',0.00339),
                                    (2018,'Commercial - A2','Temporary Supply',0.0013),
                                    (2018,'General Services-A3','General Services-A3',0.0292),
                                    (2018,'Industrial','B1',0.0041),
                                    (2018,'Industrial','B1 Peak',0.0036),
                                    (2018,'Industrial','B1 Off-Peak',0.0198),
                                    (2018,'Industrial','B2',0.0022),
                                    (2018,'Industrial','B2 - TOU (Peak)',0.0133),
                                    (2018,'Industrial','B2 - TOU (Off-peak)',0.0733),
                                    (2018,'Industrial','B3 - TOU (Peak)',0.01),
                                    (2018,'Industrial','B3 - TOU (Off-peak)',0.0869),
                                    (2018,'Industrial','B4 - TOU (Peak)',0.0047),
                                    (2018,'Industrial','B4 - TOU (Off-peak)',0.0311),
                                    (2018,'Industrial','Temporary Supply',0.0001),
                                    (2018,'Single Point Supply for further distribution','C1(a) Supply at 400 Volts-less than 5 kW',0.0001),
                                    (2018,'Single Point Supply for further distribution','C1(b) Supply at 400 Volts-exceeding 5 kW',0.0014),
                                    (2018,'Single Point Supply for further distribution','C1(b) Supply at 400 Volts-exceeding 5 kW Time of Use (TOU) - Peak',0.0007),
                                    (2018,'Single Point Supply for further distribution','C1(b) Supply at 400 Volts-exceeding 5 kW Time of Use (TOU) - Off-Peak',0.0031),
                                    (2018,'Single Point Supply for further distribution','C2 Supply at 11 kV',0.003),
                                    (2018,'Single Point Supply for further distribution','C2 Supply at 11 kV Time of Use (TOU) - Peak',0.0034),
                                    (2018,'Single Point Supply for further distribution','C2 Supply at 11 kV Time of Use (TOU) - Off-Peak',0.0151),
                                    (2018,'Single Point Supply for further distribution','C3 Supply above 11 kV',0.0012),
                                    (2018,'Single Point Supply for further distribution','C3 Supply above 11 kV Time of Use (TOU) - Peak',0.0013),
                                    (2018,'Single Point Supply for further distribution','C3 Supply above 11 kV Time of Use (TOU) - Off-Peak',0.0056),
                                    (2018,'Agricultural Tube-wells - Tariff D','Scarp',0.0039),
                                    (2018,'Agricultural Tube-wells - Tariff D','Scarp Time of Use (TOU) - Peak',0.0008),
                                    (2018,'Agricultural Tube-wells - Tariff D','Scarp Time of Use (TOU) - Off-Peak',0.0043),
                                    (2018,'Agricultural Tube-wells - Tariff D','Agricultual Tube-wells',0.0432),
                                    (2018,'Agricultural Tube-wells - Tariff D','Agricultual Tube-wells Time of Use (TOU) - Peak',0.0102),
                                    (2018,'Agricultural Tube-wells - Tariff D','Agricultual Tube-wells Time of Use (TOU) - Off-Peak',0.0484),
                                    (2018,'Others','Public Lighting - Tariff G',0.0037),
                                    (2018,'Others','Residential Colonies',0.0004),
                                    (2018,'Others','Tariff K - AJK',0.0053),
                                    (2018,'Others','Tariff K - AJK Time of Use (TOU) - Peak',0.0027),
                                    (2018,'Others','Tariff K - AJK Time of Use (TOU) - Off-Peak',0.0114),
                                    (2018,'Others','Tariff K -Rawat Lab',0.00000266),
                                    (2018,'Others','Tariff I- Railway Traction',0.00);
                                    
                                    
DROP PROCEDURE IF EXISTS fillup_ene_mix;
delimiter //
CREATE PROCEDURE fillup_ene_mix()

BEGIN
DECLARE init INT unsigned DEFAULT 2019;


	WHILE init <= 2030 DO
		INSERT INTO revenue_energy_inputs_for_cem.energy_mix_pctage(FiscalYear,Sector,Category,Percentage) VALUES(init,'Residential','Up to 50 Units',0.0215),
									(init,'Residential','01-100 Units (Peak Load<5kW)',0.144),
									(init,'Residential','101-200 Units  (Peak Load<5kW)',0.1109),
									(init,'Residential','201-300 Units  (Peak Load<5kW)',0.0994),
									(init,'Residential','301-700 Units  (Peak Load<5kW)',0.0552),
                                    (init,'Residential','Above 700 Units  (Peak Load<5kW)',0.0172),
                                    (init,'Residential','Time of Use (TOU) - Peak  (Peak Load>5kW)',0.0058),
                                    (init,'Residential','Time of Use (TOU) - Off-Peak  (Peak Load>5kW)',0.0271),
                                    (init,'Residential','Temporary Supply',0.0000427),
                                    (init,'Commercial - A2','Peak Load<5kW',0.0275),
                                    (init,'Commercial - A2','Regular  (Peak Load>5kW)',0.001),
									(init,'Commercial - A2','Time of Use (TOU) - Peak  (Peak Load>5kW)',0.0079),
                                    (init,'Commercial - A2','Time of Use (TOU) - Off-Peak  (Peak Load>5kW)',0.00339),
                                    (init,'Commercial - A2','Temporary Supply',0.0013),
                                    (init,'General Services-A3','General Services-A3',0.0292),
                                    (init,'Industrial','B1',0.0041),
                                    (init,'Industrial','B1 Peak',0.0036),
                                    (init,'Industrial','B1 Off-Peak',0.0198),
                                    (init,'Industrial','B2',0.0022),
                                    (init,'Industrial','B2 - TOU (Peak)',0.0133),
                                    (init,'Industrial','B2 - TOU (Off-peak)',0.0733),
                                    (init,'Industrial','B3 - TOU (Peak)',0.01),
                                    (init,'Industrial','B3 - TOU (Off-peak)',0.0869),
                                    (init,'Industrial','B4 - TOU (Peak)',0.0047),
                                    (init,'Industrial','B4 - TOU (Off-peak)',0.0311),
                                    (init,'Industrial','Temporary Supply',0.0001),
                                    (init,'Single Point Supply for further distribution','C1(a) Supply at 400 Volts-less than 5 kW',0.0001),
                                    (init,'Single Point Supply for further distribution','C1(b) Supply at 400 Volts-exceeding 5 kW',0.0014),
                                    (init,'Single Point Supply for further distribution','C1(b) Supply at 400 Volts-exceeding 5 kW Time of Use (TOU) - Peak',0.0007),
                                    (init,'Single Point Supply for further distribution','C1(b) Supply at 400 Volts-exceeding 5 kW Time of Use (TOU) - Off-Peak',0.0031),
                                    (init,'Single Point Supply for further distribution','C2 Supply at 11 kV',0.003),
                                    (init,'Single Point Supply for further distribution','C2 Supply at 11 kV Time of Use (TOU) - Peak',0.0034),
                                    (init,'Single Point Supply for further distribution','C2 Supply at 11 kV Time of Use (TOU) - Off-Peak',0.0151),
                                    (init,'Single Point Supply for further distribution','C3 Supply above 11 kV',0.0012),
                                    (init,'Single Point Supply for further distribution','C3 Supply above 11 kV Time of Use (TOU) - Peak',0.0013),
                                    (init,'Single Point Supply for further distribution','C3 Supply above 11 kV Time of Use (TOU) - Off-Peak',0.0056),
                                    (init,'Agricultural Tube-wells - Tariff D','Scarp',0.0039),
                                    (init,'Agricultural Tube-wells - Tariff D','Scarp Time of Use (TOU) - Peak',0.0008),
                                    (init,'Agricultural Tube-wells - Tariff D','Scarp Time of Use (TOU) - Off-Peak',0.0043),
                                    (init,'Agricultural Tube-wells - Tariff D','Agricultual Tube-wells',0.0432),
                                    (init,'Agricultural Tube-wells - Tariff D','Agricultual Tube-wells Time of Use (TOU) - Peak',0.0102),
                                    (init,'Agricultural Tube-wells - Tariff D','Agricultual Tube-wells Time of Use (TOU) - Off-Peak',0.0484),
                                    (init,'Others','Public Lighting - Tariff G',0.0037),
                                    (init,'Others','Residential Colonies',0.0004),
                                    (init,'Others','Tariff K - AJK',0.0053),
                                    (init,'Others','Tariff K - AJK Time of Use (TOU) - Peak',0.0027),
                                    (init,'Others','Tariff K - AJK Time of Use (TOU) - Off-Peak',0.0114),
                                    (init,'Others','Tariff K -Rawat Lab',0.00000266),
                                    (init,'Others','Tariff I- Railway Traction',0.00);
		SET init = init + 1;
	END WHILE;

END//
delimiter ;
CALL fillup_ene_mix();                                    
                                    

SELECT * FROM energy_mix_pctage;

-- _______________________________________________________________________Total Year-Wise Consumption with AT&C Losses_______________________________________________________________________________________________________________________


DROP TABLE IF EXISTS input_and_assumptions_for_cem.Total_Disco_Energy_losses;
CREATE TABLE IF NOT EXISTS input_and_assumptions_for_cem.Total_Disco_Energy_losses (Year VARCHAR(25),Total_losses_pct DECIMAL (10,8),Total_Consumption_with_ATC_Losses DECIMAL(20,4));

INSERT INTO input_and_assumptions_for_cem.total_disco_energy_losses(Year)   
SELECT DISTINCT CASE WHEN MONTH(Date) < 7 THEN YEAR(Date)
ELSE YEAR(Date)+1 END AS 'FiscalYear'
FROM ppp_fy2020_2030_annex4.energy_fuel_charges_mlnrs 
WHERE Date NOT IN(SELECT Date FROM input_and_assumptions_for_cem.Distribution_Margin_BlnRs);
	

DROP PROCEDURE IF EXISTS fillup_tot_losses;
delimiter //
CREATE PROCEDURE fillup_tot_losses()

BEGIN
DECLARE init INT unsigned DEFAULT 2020;


WHILE init <= 2030 DO
UPDATE input_and_assumptions_for_cem.total_disco_energy_losses SET Total_losses_pct = ((
																				(SELECT Sum_GWh FROM ppp_fy2020_2030_annex4.fy_disco_wise_energy WHERE FiscalYear=init AND DISCO='IESCO') * (SELECT Percentage FROM input_and_assumptions_for_cem.disco_losses WHERE Year=init AND DISCO='IESCO')
                                                                                + (SELECT Sum_GWh FROM ppp_fy2020_2030_annex4.fy_disco_wise_energy WHERE FiscalYear=init AND DISCO='LESCO') * (SELECT Percentage FROM input_and_assumptions_for_cem.disco_losses WHERE Year=init AND DISCO='LESCO')
                                                                                + (SELECT Sum_GWh FROM ppp_fy2020_2030_annex4.fy_disco_wise_energy WHERE FiscalYear=init AND DISCO='GEPCO') * (SELECT Percentage FROM input_and_assumptions_for_cem.disco_losses WHERE Year=init AND DISCO='GEPCO')
                                                                                + (SELECT Sum_GWh FROM ppp_fy2020_2030_annex4.fy_disco_wise_energy WHERE FiscalYear=init AND DISCO='MEPCO') * (SELECT Percentage FROM input_and_assumptions_for_cem.disco_losses WHERE Year=init AND DISCO='MEPCO')
                                                                                + (SELECT Sum_GWh FROM ppp_fy2020_2030_annex4.fy_disco_wise_energy WHERE FiscalYear=init AND DISCO='FESCO') * (SELECT Percentage FROM input_and_assumptions_for_cem.disco_losses WHERE Year=init AND DISCO='FESCO')
                                                                                + (SELECT Sum_GWh FROM ppp_fy2020_2030_annex4.fy_disco_wise_energy WHERE FiscalYear=init AND DISCO='HESCO') * (SELECT Percentage FROM input_and_assumptions_for_cem.disco_losses WHERE Year=init AND DISCO='HESCO')
                                                                                + (SELECT Sum_GWh FROM ppp_fy2020_2030_annex4.fy_disco_wise_energy WHERE FiscalYear=init AND DISCO='PESCO') * (SELECT Percentage FROM input_and_assumptions_for_cem.disco_losses WHERE Year=init AND DISCO='PESCO')
                                                                                + (SELECT Sum_GWh FROM ppp_fy2020_2030_annex4.fy_disco_wise_energy WHERE FiscalYear=init AND DISCO='QESCO') * (SELECT Percentage FROM input_and_assumptions_for_cem.disco_losses WHERE Year=init AND DISCO='QESCO')
                                                                                + (SELECT Sum_GWh FROM ppp_fy2020_2030_annex4.fy_disco_wise_energy WHERE FiscalYear=init AND DISCO='TESCO') * (SELECT Percentage FROM input_and_assumptions_for_cem.disco_losses WHERE Year=init AND DISCO='TESCO')
                                                                                + (SELECT Sum_GWh FROM ppp_fy2020_2030_annex4.fy_disco_wise_energy WHERE FiscalYear=init AND DISCO='SEPCO') * (SELECT Percentage FROM input_and_assumptions_for_cem.disco_losses WHERE Year=init AND DISCO='SEPCO') 
                                                                                )/(SELECT SUM(Sum_GWh) FROM ppp_fy2020_2030_annex4.fy_disco_wise_energy WHERE FiscalYear=init AND DISCO<>'KESC'))  WHERE Year=init; 

SET init = init + 1;
	END WHILE;

END//
delimiter ;
CALL fillup_tot_losses();  

DROP PROCEDURE IF EXISTS fillup_tot_consumption;
delimiter //
CREATE PROCEDURE fillup_tot_consumption()

BEGIN
DECLARE init INT unsigned DEFAULT 2020;


WHILE init <= 2030 DO

UPDATE input_and_assumptions_for_cem.total_disco_energy_losses SET Total_Consumption_with_ATC_Losses = (SELECT * FROM(
																										SELECT ((1-input_and_assumptions_for_cem.total_disco_energy_losses.Total_losses_pct)*ppp_fy2020_2030_annex4.fy_grouped_disco_wise_energy.Sum_GWh)
																										FROM input_and_assumptions_for_cem.total_disco_energy_losses
																										INNER JOIN ppp_fy2020_2030_annex4.fy_grouped_disco_wise_energy ON 
																										input_and_assumptions_for_cem.total_disco_energy_losses.Year=ppp_fy2020_2030_annex4.fy_grouped_disco_wise_energy.FiscalYear
																										AND input_and_assumptions_for_cem.total_disco_energy_losses.Year=init) as temptbl2) where Year=init;
                                                                                 
SET init = init + 1;
	END WHILE;

END//
delimiter ;
CALL fillup_tot_consumption();  

-- SELECT FiscalYear,SUM(GWh) FROm FY_category_wise_forecasted_gwh_consumption_pms_based GROUP BY FiscalYear;
SELECT * FROM input_and_assumptions_for_cem.total_disco_energy_losses;

-- ____________________________________________________________Tariff (True Cost)________________________________________________________________________________________________________________________________________________________________________________________________
use tariff_true_cost;

-- ALTER TABLE national_avg_tariff ADD Value DECIMAL(20,4);



UPDATE national_avg_tariff SET Value=0.427478278 where Sector='Commercial - A2' AND Category='Regular  (Peak Load>5kW)' AND Parameter='Load Factor(%)';
UPDATE national_avg_tariff SET Value=0.317492111 where Sector='Commercial - A2' AND Category='Time of Use (TOU) - Off-Peak  (Peak Load>5kW)' AND Parameter='Load Factor(%)';
UPDATE national_avg_tariff SET Value=0.402340797 where Sector='Industrial' AND Category='B2' AND Parameter='Load Factor(%)';
UPDATE national_avg_tariff SET Value=0.315558086 where Sector='Industrial' AND Category='B2 - TOU (Off-peak)' AND Parameter='Load Factor(%)';
UPDATE national_avg_tariff SET Value=0.549807816 where Sector='Industrial' AND Category='B3 - TOU (Off-peak)' AND Parameter='Load Factor(%)';
UPDATE national_avg_tariff SET Value=0.581921867 where Sector='Industrial' AND Category='B4 - TOU (Off-peak)' AND Parameter='Load Factor(%)';
UPDATE national_avg_tariff SET Value=0.542215631 where Sector='Single Point Supply for further distribution' AND Category='C1(b) Supply at 400 Volts-exceeding 5 kW' AND Parameter='Load Factor(%)';
UPDATE national_avg_tariff SET Value=0.456160944 where Sector='Single Point Supply for further distribution' AND Category='C1(b) Supply at 400 Volts-exceeding 5 kW Time of Use (TOU) - Off-Peak' AND Parameter='Load Factor(%)';
UPDATE national_avg_tariff SET Value=0.647180559 where Sector='Single Point Supply for further distribution' AND Category='C2 Supply at 11 kV' AND Parameter='Load Factor(%)';
UPDATE national_avg_tariff SET Value=0.517009651 where Sector='Single Point Supply for further distribution' AND Category='C2 Supply at 11 kV Time of Use (TOU) - Off-Peak' AND Parameter='Load Factor(%)';
UPDATE national_avg_tariff SET Value=0.795626334 where Sector='Single Point Supply for further distribution' AND Category='C3 Supply above 11 kV' AND Parameter='Load Factor(%)';
UPDATE national_avg_tariff SET Value=0.566348179 where Sector='Single Point Supply for further distribution' AND Category='C3 Supply above 11 kV Time of Use (TOU) - Off-Peak' AND Parameter='Load Factor(%)';
UPDATE national_avg_tariff SET Value=0.407777543 where Sector='Agricultural Tube-wells - Tariff D' AND Category='Scarp Time of Use (TOU) - Off-Peak' AND Parameter='Load Factor(%)';
UPDATE national_avg_tariff SET Value=0.415846542 where Sector='Agricultural Tube-wells - Tariff D' AND Category='Agricultual Tube-wells' AND Parameter='Load Factor(%)';
UPDATE national_avg_tariff SET Value=0.214084054 where Sector='Agricultural Tube-wells - Tariff D' AND Category='Agricultual Tube-wells Time of Use (TOU) - Off-Peak' AND Parameter='Load Factor(%)';
UPDATE national_avg_tariff SET Value=0.455485139 where Sector='Others' AND Category='Tariff K - AJK' AND Parameter='Load Factor(%)';
UPDATE national_avg_tariff SET Value=0.464325462 where Sector='Others' AND Category='Tariff K - AJK Time of Use (TOU) - Off-Peak' AND Parameter='Load Factor(%)';

UPDATE national_avg_tariff SET Value=400 where Sector='Commercial - A2' AND Category='Regular  (Peak Load>5kW)' AND Parameter='Fixed Charge(Rs/kW/M)';
UPDATE national_avg_tariff SET Value=400 where Sector='Commercial - A2' AND Category='Time of Use (TOU) - Off-Peak  (Peak Load>5kW)' AND Parameter='Fixed Charge(Rs/kW/M)';
UPDATE national_avg_tariff SET Value=400 where Sector='Industrial' AND Category='B2' AND Parameter='Fixed Charge(Rs/kW/M)';
UPDATE national_avg_tariff SET Value=400 where Sector='Industrial' AND Category='B2 - TOU (Off-peak)' AND Parameter='Fixed Charge(Rs/kW/M)';
UPDATE national_avg_tariff SET Value=380 where Sector='Industrial' AND Category='B3 - TOU (Off-peak)' AND Parameter='Fixed Charge(Rs/kW/M)';
UPDATE national_avg_tariff SET Value=360 where Sector='Industrial' AND Category='B4 - TOU (Off-peak)' AND Parameter='Fixed Charge(Rs/kW/M)';
UPDATE national_avg_tariff SET Value=400 where Sector='Single Point Supply for further distribution' AND Category='C1(b) Supply at 400 Volts-exceeding 5 kW' AND Parameter='Fixed Charge(Rs/kW/M)';
UPDATE national_avg_tariff SET Value=400 where Sector='Single Point Supply for further distribution' AND Category='C1(b) Supply at 400 Volts-exceeding 5 kW Time of Use (TOU) - Off-Peak' AND Parameter='Fixed Charge(Rs/kW/M)';
UPDATE national_avg_tariff SET Value=380 where Sector='Single Point Supply for further distribution' AND Category='C2 Supply at 11 kV' AND Parameter='Fixed Charge(Rs/kW/M)';
UPDATE national_avg_tariff SET Value=380 where Sector='Single Point Supply for further distribution' AND Category='C2 Supply at 11 kV Time of Use (TOU) - Off-Peak' AND Parameter='Fixed Charge(Rs/kW/M)';
UPDATE national_avg_tariff SET Value=360 where Sector='Single Point Supply for further distribution' AND Category='C3 Supply above 11 kV' AND Parameter='Fixed Charge(Rs/kW/M)';
UPDATE national_avg_tariff SET Value=360 where Sector='Single Point Supply for further distribution' AND Category='C3 Supply above 11 kV Time of Use (TOU) - Off-Peak' AND Parameter='Fixed Charge(Rs/kW/M)';
UPDATE national_avg_tariff SET Value=200 where Sector='Agricultural Tube-wells - Tariff D' AND Category='Scarp Time of Use (TOU) - Off-Peak' AND Parameter='Fixed Charge(Rs/kW/M)';
UPDATE national_avg_tariff SET Value=200 where Sector='Agricultural Tube-wells - Tariff D' AND Category='Agricultual Tube-wells' AND Parameter='Fixed Charge(Rs/kW/M)';
UPDATE national_avg_tariff SET Value=200 where Sector='Agricultural Tube-wells - Tariff D' AND Category='Agricultual Tube-wells Time of Use (TOU) - Off-Peak' AND Parameter='Fixed Charge(Rs/kW/M)';
UPDATE national_avg_tariff SET Value=360 where Sector='Others' AND Category='Tariff K - AJK' AND Parameter='Fixed Charge(Rs/kW/M)';
UPDATE national_avg_tariff SET Value=360 where Sector='Others' AND Category='Tariff K - AJK Time of Use (TOU) - Off-Peak' AND Parameter='Fixed Charge(Rs/kW/M)';

/*
UPDATE national_avg_tariff SET Value= (CASE WHEN ((SELECT Value 
										/ (SELECT ((Sum_CPP_MlnRs/1000+UoSC_MoF_withoutKE_MlnRs/1000-UoSC_MoF_KEonly_MlnRs/1000)*POW(10,9))/((SELECT Sum(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.AVG_OF_FY_MAX_DEMAND where FiscalYear=2020 GROUP BY FiscalYear)*1000) FROM FY_UoSC_MoF_withoutKE_MlnRs  INNER JOIN
											FY_UoSC_MoF_KEonly_MlnRs ON FY_UoSC_MoF_withoutKE_MlnRs.FiscalYear=FY_UoSC_MoF_KEonly_MlnRs.FiscalYear 
											INNER JOIN fy_cpp_exclke_mlnrs 
											ON FY_UoSC_MoF_KEonly_MlnRs.FiscalYear=fy_cpp_exclke_mlnrs.FiscalYear AND
                                            FY_UoSC_MoF_withoutKE_MlnRs.FiscalYear=2020 AND 
                                            FY_UoSC_MoF_KEonly_MlnRs.FiscalYear=2020)
											FROM tariff_true_cost.national_avg_tariff WHERE Sector='Residential' AND Category='Up to 50 Units' AND Parameter= 'Fixed Charge(Rs/kW/M)' AND FiscalYear=2020))<>NULL
									THEN 
											((SELECT Value 
										/ (SELECT ((Sum_CPP_MlnRs/1000+UoSC_MoF_withoutKE_MlnRs/1000-UoSC_MoF_KEonly_MlnRs/1000)*POW(10,9))/((SELECT Sum(Sum_of_AvgMW) FROM ppp_fy2020_2030_annex4.AVG_OF_FY_MAX_DEMAND where FiscalYear=2020 GROUP BY FiscalYear)*1000) FROM FY_UoSC_MoF_withoutKE_MlnRs  INNER JOIN
											FY_UoSC_MoF_KEonly_MlnRs ON FY_UoSC_MoF_withoutKE_MlnRs.FiscalYear=FY_UoSC_MoF_KEonly_MlnRs.FiscalYear 
											INNER JOIN fy_cpp_exclke_mlnrs 
											ON FY_UoSC_MoF_KEonly_MlnRs.FiscalYear=fy_cpp_exclke_mlnrs.FiscalYear)
											FROM tariff_true_cost.national_avg_tariff WHERE Sector='Others' AND Category='Residential Colonies' AND Parameter= 'Fixed Charge(Rs/kW/M)' AND FiscalYear=2020))
											ELSE NULL END) where FiscalYear=2020 AND Parameter='Fixed Charge(%)'; 
*/
select *  
 FROM tariff_true_cost.national_avg_tariff where FiscalYear=2021 ;--  AND Sector='';

 /*
((SELECT Value/(Select Sum_CPP_MlnRs from ppp_fy2020_2030_annex4.FY_CPP_exclKE_MlnRs where FiscalYear=2020) FROM tariff_true_cost.national_avg_tariff WHERE Sector='Others' AND Category='Regular  (Peak Load>5kW)' AND Parameter= 'Fixed Charge(Rs/kW/M)' AND FiscalYear=2020)); 


SELECT * FROM energy_mix_pctage;
SELECT Sum(Total_RR_BlnRs) FROM input_and_assumptions_for_cem.total_revenue_requirements where Date=2024 GROUP By Date;

SELECT(SELECT(revenue_energy_inputs_for_cem.energy_mix_pctage.Percentage*
									(SELECT Sum(Total_RR_BlnRs) FROM input_and_assumptions_for_cem.total_revenue_requirements where Date=2021 GROUP By Date)) 
                                    FROM revenue_energy_inputs_for_cem.energy_mix_pctage where revenue_energy_inputs_for_cem.energy_mix_pctage.Sector = 'Others' 
                                    AND revenue_energy_inputs_for_cem.energy_mix_pctage.Category='Residential Colonies' 
                                    AND revenue_energy_inputs_for_cem.energy_mix_pctage.FiscalYear=2021)*
                                    1000-(SELECT Value FROM tariff_true_cost.national_avg_tariff where tariff_true_cost.national_avg_tariff.Sector='Others' AND tariff_true_cost.national_avg_tariff.Category='Residential Colonies' 
                                    AND tariff_true_cost.national_avg_tariff.FiscalYear=2021 AND tariff_true_cost.national_avg_tariff.Parameter='Fixed Charge(MlnRs)')
-- input_and_assumptions_for_cem.total_revenue_requirements ON
-- input_and_assumptions_for_cem.total_revenue_requirements.Date=revenue_energy_inputs_for_cem.energy_mix_pctage.FiscalYear INNER JOIN
-- tariff_true_cost.national_avg_tariff ON
-- tariff_true_cost.national_avg_tariff.Sector=revenue_energy_inputs_for_cem.energy_mix_pctage.Sector AND 
-- tariff_true_cost.national_avg_tariff.category=revenue_energy_inputs_for_cem.energy_mix_pctage.Category;

*/



