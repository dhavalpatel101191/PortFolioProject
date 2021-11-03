/*----------------------Data Cleaning By Sql----------------------

------------------------------------------------------------------*/


select top 10 * from dbo.Housing;

-------------------------------------------------------------Standardize  SaleDate----------------------------------------

select top 10 SaleDate from dbo.Housing;

select SaleDate,Convert(date,SaleDate)
from dbo.Housing;

Update dbo.Housing
set SaleDate = Convert(date,SaleDate);

Alter table dbo.Housing
add  SaleDateConverted Date;

Update dbo.Housing
set SaleDateConverted = Convert(date,SaleDate);

select top 10 SaleDateConverted from dbo.Housing;

Alter table dbo.housing
drop column SaleDate;

--------------------------------------------------Populate Property Address Data--------------------------------------

select PropertyAddress
from dbo.Housing
where PropertyAddress is Null;


select *
from dbo.Housing
where PropertyAddress is Null;

select PropertyAddress
from dbo.Housing
where PropertyAddress is Null;

select *
from dbo.Housing
order by ParcelID;

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from dbo.Housing a
join dbo.Housing b
     on a.ParcelID = b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is Null;

Update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from dbo.Housing a
join dbo.Housing b
     on a.ParcelID = b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is Null;

-----------------------------Breaking Out Address into Individual Columns (Address,City,State)-----------------------------------------

select top 10 * from dbo.Housing;

Select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,len(PropertyAddress)) as State
from dbo.Housing;

Alter table dbo.housing
add PropertySplitAddress varchar(255);

Update dbo.Housing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1);

Alter table dbo.housing
add PropertySplitState varchar(255);

Update dbo.Housing
set PropertySplitState = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,len(PropertyAddress));


------------------------------------Owner Address----------------------------------------------------

select OwnerAddress
from dbo.Housing;

select
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
from dbo.Housing;

Alter table dbo.housing
add OwnerSplitAddress varchar(255);

Update dbo.Housing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3);

Alter table dbo.housing
add OwnerSplitCity varchar(255);

Update dbo.Housing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2);

Alter table dbo.housing
add OwnerSplitState varchar(255);

Update dbo.Housing
set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1);


-----------------------------Change Y and N to Yes and No in "SoldAsVacant" field---------------------------

select distinct SoldAsVacant
from dbo.Housing;

select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End
from dbo.Housing;

Update dbo.Housing
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
                        when SoldAsVacant = 'N' then 'No'
	                    Else SoldAsVacant
	                    End;


-----------------------------------Remove Duplicates---------------------------------

With RowNumCTE AS 
(
Select *,
       ROW_NUMBER() over(
       Partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 Order By UniqueID
			             ) row_num
from dbo.Housing
)
Select *
from RowNumCTE
where row_num >1
Order by PropertyAddress;


With RowNumCTE AS 
(
Select *,
       ROW_NUMBER() over(
       Partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 Order By UniqueID
			             ) row_num
from dbo.Housing
)
Delete
from RowNumCTE
where row_num >1;

-----------------------------Delete Unused Column-----------------------------

Select *
from dbo.Housing;

Alter table dbo.Housing
drop column OwnerAddress,TaxDistrict,PropertyAddress;

