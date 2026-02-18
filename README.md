# Global Company Layoffs SQL Analysis

## Project Overview
This project analyzes global layoffs of companies accross industries and countries between March 2020 and March 2023 using SQL.
The dataset was cleaned, standardized, and analyzed to uncover trends across companies, countries, and time periods.

## Data Cleaning Process
<li>Removed duplicate records using ROW_NUMBER()</li>
<li>Standardized industry and country values</li>
<li>Converted date column to DATE format</li>
<li>Populated missing industry values using self-joins</li>
<li>Removed records with no layoff data</li>

## Key Insights
<li>total number of global layoffs between march 2020 and march 2023 = 382,820</li>
<li>layoffs peaked in 2023 with 125,677 total layoffs accross countries and industries with just 3 months of data compared to previous years of 12 months</li>
<li>The United States recorded the highest layoffs at 256,420 in three years between march 2020 and march 2023</li>
<li>Amazon has the highest total layoffs of 18,150</li>
<li>Late-stage companies experienced the highest layoffs peaking at post-IPO with 204,073 layoffs.</li>
<li>Monthly analysis revealed a spike in january 2023 with 84,714 layoffs</li>

## Tools Used
<li>MySQL</li>
<li>Window Functions</li>
<li>CTEs</li>
<li>Aggregate Functions</li>

