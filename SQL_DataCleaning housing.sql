/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[NashvilleHousing]

  --Cleaning Data in SQl Queries

  Select * 
  From PortfolioProject.dbo.NashvilleHousing 

 -- Standardize Data Format

   Select SaleDateConverted,Convert(Date,SaleDate )
  From PortfolioProject.dbo.NashvilleHousing 

  Update NashvilleHousing 
  Set SaleDate = Convert(Date,SaleDate )

  Alter Table NashvilleHousing
  Add SaleDateConverted Date;

  Update NashvilleHousing 
  Set SaleDateConverted = Convert(Date,SaleDate )

  --Populate Property Address Date 

  Select * 
  From PortfolioProject.dbo.NashvilleHousing 
  --Where PropertyAddress is null
  order by ParcelID 


  
  Select a.ParcelID , a.PropertyAddress ,b.ParcelID, b.PropertyAddress, Isnull(a.PropertyAddress,b.PropertyAddress) 
  From PortfolioProject.dbo.NashvilleHousing a
  Join PortfolioProject.dbo.NashvilleHousing b
  on a.ParcelID = b.ParcelID  
  And a.[UniqueID ] <>b.[UniqueID ] 
  Where a.PropertyAddress is null

  update a
  Set PropertyAddress = Isnull(a.PropertyAddress,b.PropertyAddress) 
   From PortfolioProject.dbo.NashvilleHousing a
  Join PortfolioProject.dbo.NashvilleHousing b
  on a.ParcelID = b.ParcelID  
  And a.[UniqueID ] <>b.[UniqueID ] 

  --Breaking out Address into Individual Columns(Address,City, State) 

    Select PropertyAddress
  From PortfolioProject.dbo.NashvilleHousing 
  --Where PropertyAddress is null
  order by ParcelID

  Select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
         SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address

    From PortfolioProject.dbo.NashvilleHousing 
	
	
  Alter Table NashvilleHousing
  Add PropertySplitAddress Nvarchar(255);

  Update NashvilleHousing 
  Set PropertySplitAddress =  SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

  
  Alter Table NashvilleHousing
  Add PropertySplitcity Nvarchar(255);

  Update NashvilleHousing 
  Set PropertySplitcity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


   Select OwnerAddress 
  From PortfolioProject.dbo.NashvilleHousing 

  Select 
  PARSENAME(REPLACE(OwnerAddress,',','.'),3) ,
  PARSENAME(REPLACE(OwnerAddress,',','.'),2) ,
  PARSENAME(REPLACE(OwnerAddress,',','.'),1) 
   From PortfolioProject.dbo.NashvilleHousing 

   Alter Table NashvilleHousing
  Add OwnerSplitAddress Nvarchar(255);

  Update NashvilleHousing 
  Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3) 

  
   Alter Table NashvilleHousing
  Add OwnerSplitCity Nvarchar(255);

  Update NashvilleHousing 
  Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2) 

     Alter Table NashvilleHousing
  Add OwnerSplitState Nvarchar(255);

  Update NashvilleHousing 
  Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1) 


  
   Select * 
  From PortfolioProject.dbo.NashvilleHousing 

  --Change Y and N to Yes and NO in "Sold" as Vacant" field

   Select Distinct(SoldAsVacant ),Count(SoldAsVacant )
  From PortfolioProject.dbo.NashvilleHousing 
   Group by SoldAsVacant
   Order by 2


    Select SoldAsVacant, 
	CASE When SoldAsVacant='Y' then 'Yes'
		When SoldAsVacant='N' then 'No'
		Else SoldAsVacant
		End
	 
  From PortfolioProject.dbo.NashvilleHousing 

  Update NashvilleHousing 
  Set  SoldAsVacant=CASE When SoldAsVacant='Y' then 'Yes'
		When SoldAsVacant='N' then 'No'
		Else SoldAsVacant
		End
   
  From PortfolioProject.dbo.NashvilleHousing 

  --Remove Duplicates

  With RowNumCTE as
  (Select *,
  Row_number() OVER (
  Partition by 
  ParcelID,
  PropertyAddress, 
  SalePrice,
  SaleDate,
  LegalReference
  Order by UniqueID ) row_num
From PortfolioProject.dbo.NashvilleHousing )

	Select *
	From RowNumCTE
	Where row_num>1
	order by propertyAddress


	--Delete Unused Columns

	Select* 
	From PortfolioProject.dbo.NashvilleHousing 

	ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
	DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress

