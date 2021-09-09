# Covid-SQL

**Zadání:**

Vytvoření tabulky obsahující panelová data pro model, který bude vysvětlovat průběh pandemie v závislosti na ekonomických, demografických a geografických vlivech. Pro získání vhodné proměnné jsem do finální tabulky zahrnula následující data:

date (rok 2020) / country / confirmed / tests_performed / weekend / year_season / population_density / GDP_per_resident / mortaliy_under5 - použita data za rok 2019, pro rok 2020 nejsou údaje / median_age_2018 / gini / life_exp_1965 / life_exp_2015 / life_exp_diff / religion_perc - procentní podíl jednotlivých náboženství v jednotlivých zemích / temp_day - průměrná denní teplota / hours_rain_day - počet hodin, kdy byly nenulové srážky / wind_km/h - síla větru.

Zdroj dat - tabulky: 

countries, economies, life_expectancy, religions, covid19_basic_differences, covid19_testing, weather, lookup_table 


**Postup:**

Z důvodu poměrně velkého množství různorodých dat jsem se pro přehlednost rozhodla vytvořit  tři temporary tabulky, z kterých jsem pak vytvořila finální tabulku t_barbora_fryblikova_projekt_SQL_final.

1. temporary table - temp_cov19_eco_dem_project

V první temporary tabulce jsou zahrnuta data týkající se počtu nakažených, testovaných, weekend, ročních období, ekonomických údajů - GDP, Gini, demografických údajů - hustoty zalidnení, dětské úmrtnosti a dožití.

Vyjma stanovených případů, v nichž jsem měla použít data z jiných let, jsem v selectech omezila vše na rok 2020.

Výstup - tabulka obsahující sloupce:

date / country  / confirmed / tests_performed / weekend / year_season / population_density / GDP_per_resident / mortaliy_under5 / median_age_2018 / gini / life_exp_1965 / life_exp_2015 /  life_exp_diff.


2. temporary table - temp_religion_project

V druhé temporary tabulce je uvedeno procentní rozdělení jednotlivých náboženství v jednotlivých zemích. Stejně jako v předchozí tabulce jsem pracovala s údaji pro rok 2020. Pro každé náboženství jsem vytvořila vlastní sloupec, v němž jsem spočítala podíl populace hlásící se k jednotlivým náboženství ku celkové populaci. SUM populace v tabulce religions nesedí na tabulku countries, pro účely výpočtu jsem použila SUM populace v tabulce religions, kterou jsem pak pomocí GROUP BY rozložila na jednotlivé země.

Výstup - tabulka obsahující sloupce:

country / christianity_perc / islam_perc / buddhism_perc / folk_rel_perc / hinduism_perc / other_rel_perc.


3. temporary table - temp_weather_project

V poslední temporary tabulce bylo zapotřebí provést úpravy dat, zejména jejich oříznutí.Ve sloupci date byla použita funce SUBSTRING a ve sloupcích temp a wind pak SUBSTRING_INDEX a převedení do jiného datového typu.

Výstup - tabulka obsahující sloupce:

date /country /city / temp_day / hours_rain_day / wind_km_per_h.


**Závěr**

V závěrečné fázi projektu jsem pomocí funkce LEFT JOIN spojila předešlé tři temporary tabulky přes country a date, podle potřeby a obsahu.


