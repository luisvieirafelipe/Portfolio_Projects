--Limpeza dos Dados
--Sobre os dados: Dados de Compra e Venda de Casas na Cidade de Nashville, Tennessee (EUA).


Select * From SQL_Projects..NashvilleHousing

--Padronizar Data de Venda(SaleDate)

Select SaleDate, CONVERT(date,SaleDate)
from NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)

Alter table NashvilleHousing
drop column SaleDate

Select SaleDateConverted
from NashvilleHousing

-- Preencher Dados de Endereço da Propriedade (Property Adrres)

Select *
From NashvilleHousing
Where PropertyAddress is null


Select *
From NashvilleHousing
order by ParcelID /*Olhando os dados, em ParcelIDA podemos ver endereços duplicados, então quando o ParcelIDA for igual, podemos utilizar o endereço de um para preencher o outro*/

Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, isnull(A.PropertyAddress, B.PropertyAddress) /*Quando A.PropertyAdress for Null, vai Colocar a informação de B.PropertyAdress */
From NashvilleHousing A
join NashvilleHousing B
	on A.ParcelID=B.ParcelID
	and A.[UniqueID ]<>B.[UniqueID ]
	Where A.PropertyAddress is null

Update A
Set PropertyAddress =  isnull(A.PropertyAddress, B.PropertyAddress)
From NashvilleHousing A
join NashvilleHousing B
	on A.ParcelID=B.ParcelID
	and A.[UniqueID ]<>B.[UniqueID ]
	Where A.PropertyAddress is null

Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, isnull(A.PropertyAddress, B.PropertyAddress)
From NashvilleHousing A
join NashvilleHousing B
	on A.ParcelID=B.ParcelID
	and A.[UniqueID ]<>B.[UniqueID ]

--Separando o endereço em colunas individuais de endereço, cidade e estado (Adress, City, State)

Select
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING (PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
From NashvilleHousing

alter table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING (PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Alter table NashvilleHousing
drop column PropertyAddress

Select *
From NashvilleHousing

-- Separar Endereço do dono da propriedade (OwnerAddress)

Select
PARSENAME(Replace(OwnerAddress,',','.'), 3),
PARSENAME(Replace(OwnerAddress,',','.'), 2),
PARSENAME(Replace(OwnerAddress,',','.'), 1)
From NashvilleHousing

alter table NashvilleHousing
Add OwnerSplitAdress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAdress = PARSENAME(Replace(OwnerAddress,',','.'), 3)

alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'), 2)


alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'), 1)

Alter table NashvilleHousing
drop column OwnerAddress

Select *
From NashvilleHousing

--Mudar Y e N para Yes and No (sim e não) na coluna "Sold as Vacant" 

Select distinct(SoldAsVacant), count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
case When SoldAsVacant='Y' then 'Yes'
	 When SoldAsVacant='N' then 'No'
	 Else SoldAsVacant
	 End
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = case When SoldAsVacant='Y' then 'Yes'
	 When SoldAsVacant='N' then 'No'
	 Else SoldAsVacant
	 End


Select distinct(SoldAsVacant), count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2

-- Remover Duplicatas

With RowNumCTE as (
Select *,    
	ROW_NUMBER() Over (
	Partition by ParcelID,
					PropertySplitAddress,
					SalePrice,
					SaleDateConverted,
					LegalReference
					Order by 
						UniqueID
					) row_num

From NashvilleHousing
)
Select*
from RowNumCTE
Where row_num>1
Order by PropertySplitAddress

With RowNumCTE as (
Select *,    
	ROW_NUMBER() Over (
	Partition by ParcelID,
				 PropertySplitAddress,
				 SalePrice,
				 SaleDateConverted,
				 LegalReference
				 Order by 
					UniqueID
					) row_num

From NashvilleHousing
)
Delete
from RowNumCTE
Where row_num>1

With RowNumCTE as (
Select *,   
	ROW_NUMBER() Over (
	Partition by ParcelID,
				 PropertySplitAddress,
				 SalePrice,
				 SaleDateConverted,
				 LegalReference
				 Order by 
					UniqueID
					) row_num

From NashvilleHousing
)
Select*
from RowNumCTE
Where row_num>1
Order by PropertySplitAddress

