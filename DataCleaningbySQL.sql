--Data Cleaning in SQL

SELECT *
FROM NashvilleHousing

--Standardise the date format

SELECT SaleDateConverted, CONVERT(Date, SaleDate) AS SaleDateConverted
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate=CONVERT(Date, SaleDateConverted)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted =CONVERT(Date, SaleDate)

--Populate Property Address

SELECT *
FROM NashvilleHousing
Where PropertyAddress is NULL
Order by ParcelID

SELECT  a.ParcelID, a.PropertyAddress, 
b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
on a.ParcelID =b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress= ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
on a.ParcelID =b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]


--Breaking address into indivisual column

SELECT PropertyAddress
FROM NationalHousing
--Where PropertyAddress is NULL
--Order by ParcelID

SELECT 
SUBSTRING (PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING (PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
--CHARINDEX (',', PropertyAddress)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD ProertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET ProertySplitAddress =SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD ProertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET ProertySplitCity =SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT PropertyAddress, ProertySplitAddress,ProertySplitCity
FROM NashvilleHousing



SELECT OwnerAddress
FROM NashvilleHousing

SELECT
PARSENAME (REPLACE(OwnerAddress,',','.'),3),
PARSENAME (REPLACE(OwnerAddress,',','.'),2),
PARSENAME (REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerAddSplit1 nvarchar(255);

UPDATE NashvilleHousing
SET OwnerAddSplit1 = PARSENAME (REPLACE(OwnerAddress,',','.'),3)



ALTER TABLE NashvilleHousing
ADD OwnerAddSplit2 nvarchar(255);

UPDATE NashvilleHousing
SET OwnerAddSplit2 = PARSENAME (REPLACE(OwnerAddress,',','.'),2)


ALTER TABLE NashvilleHousing
ADD OwnerAddSplit3 nvarchar(255);

UPDATE NashvilleHousing
SET OwnerAddSplit3 = PARSENAME (REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM NashvilleHousing

-- COnvert Y N or Yes NO in SoldAsVacant

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant ,
CASE When SoldAsVacant ='Y' THEN 'Yes'
	When SoldAsVacant= 'N' THEN 'No'
	ELSE SoldAsVacant
END
From NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =
CASE When SoldAsVacant ='Y' THEN 'Yes'
	When SoldAsVacant= 'N' THEN 'No'
	ELSE SoldAsVacant
END

UPDATE NashvilleHousing
SET SoldAsVacant =
CASE When SoldAsVacant ='Vacant' THEN 'Yes'
	When SoldAsVacant= 'Sold' THEN 'No'
	ELSE SoldAsVacant
END

--Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SaleDate,
				LegalReference
				OrDER BY UniqueID
				)row_num

FROM NashvilleHousing
--ORDER by ParcelID
)
Select *
From RowNumCTE
Where row_num >1
--Order by ParcelID

--Delete unused columns


SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate