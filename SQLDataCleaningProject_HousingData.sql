/*
Cleaning data in SQL queries
*/
USE PortFolioProjects

SELECT 
	*
FROM NashVilleHousing

-----------------------------
--Formatting date column

SELECT 
	SaleDate,
	CONVERT(date,SaleDate)
FROM NashVilleHousing

UPDATE NashVilleHousing
SET SaleDate = CONVERT(date,SaleDate) --If does not work, try the following lines

ALTER TABLE NashVilleHousing
ADD SaleDate2 Date;

UPDATE NashVilleHousing
SET SaleDate2 = CONVERT(DATE,SaleDate)

SELECT SaleDate,SaleDate2 FROM NashVilleHousing

-----------------------
--Populate PropertyAddress column

SELECT 
	NH1.[UniqueID ],
	NH1.ParcelID,
	NH1.PropertyAddress,
	NH2.ParcelID,
	NH2.PropertyAddress,
	ISNULL(NH1.PropertyAddress,NH2.PropertyAddress)
FROM NashVilleHousing AS NH1
	JOIN NashVilleHousing AS NH2
		ON NH1.ParcelID=NH2.ParcelID
			AND NH1.[UniqueID ]<>NH2.[UniqueID ]
WHERE NH1.PropertyAddress IS NULL
ORDER BY NH1.[UniqueID ]

UPDATE NH1
SET PropertyAddress=ISNULL(NH1.PropertyAddress,NH2.PropertyAddress)
FROM NashVilleHousing AS NH1
	JOIN NashVilleHousing AS NH2
		ON NH1.ParcelID=NH2.ParcelID
			AND NH1.[UniqueID ]<>NH2.[UniqueID ]
WHERE NH1.PropertyAddress IS NULL

--------------------------------
--Breaking out address into individual columns- Address, city, state

SELECT
	PropertyAddress,
	SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
	SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
FROM NashVilleHousing

ALTER TABLE NashVilleHousing
Add 
	PropertySplitAddress nvarchar(255);

UPDATE NashVilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashVilleHousing
Add 
	PropertySplitCity nvarchar(255);

UPDATE NashVilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT * FROM NashVilleHousing

SELECT
	PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashVilleHousing

ALTER TABLE NashVilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashVilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashVilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashVilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashVilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashVilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT * FROM NashVilleHousing

--Replace Y and N by Yes and No in SoldAsVancant column

SELECT 
	SoldAsVacant,
	COUNT(SoldAsVacant)
FROM NashVilleHousing
GROUP BY SoldAsVacant

SELECT 
	SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'	
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM NashVilleHousing

UPDATE NashVilleHousing
SET SoldAsVacant =
		CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'	
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

SELECT * FROM NashVilleHousing
--------------------------------------
----Removing Duplicates

WITH RowNumCTE AS 
(SELECT
	*,
	ROW_NUMBER() OVER 
	(PARTITION BY 
		ParcelID,
		PropertyAddress,
		SaleDate,
		SalePrice,
		LegalReference
	    ORDER BY UniqueID
	) row_num
FROM NashVilleHousing)
DELETE FROM RowNumCTE 
WHERE row_num > 1

SELECT 
	DISTINCT ROW_NUMBER() OVER
		(PARTITION BY
			ParcelID,
			PropertyAddress,
			SaleDate,
			SalePrice,
			LegalReference
			ORDER BY UniqueID
		) as row_num
FROM NashVilleHousing


-----------------------------------------------
---Delete unused columns

ALTER TABLE NashVilleHousing
DROP COLUMN PropertyAddress,OwnerAddress,TaxDistrict,SaleDate

SELECT * FROM NashVilleHousing