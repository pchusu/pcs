destpath = "C:/000/20150814_LandsatAmazonFTP/Data/"
ipath = "http://landsat-pds.s3.amazonaws.com/L8/018/029/"

days =c("010","026","042","058","074","090", seq(106,233, by=16))
days = seq(186,as.numeric(format(Sys.Date(), "%j")), by=16)
for (day in days){
print(day)
setwd(destpath)
img = paste("LC80180292015",day,"LGN00",sep="")

destfile = file.path(destpath,img)
dir.create(file.path(destfile))


for (i in 1:11){
b = paste(img,"_B",i,".TIF",sep="")
bovr = paste(img,"_B",i,".TIF.ovr",sep="")
bpath = paste(ipath,img,"/",b,sep="")
bovrpath = paste(ipath,img,"/",bovr,sep="")
download.file(bpath, file.path(destfile,b), mode="wb")
download.file(bovrpath, file.path(destfile,bovr), mode="wb")
}

bqa = paste(img,"_BQA.TIF",sep="")
bqa.ovr = paste(img,"_BQA.TIF.ovr",sep="")
bqapath = paste(ipath,img,"/",bqa,sep="")
bqaovrpath =  paste(ipath,img,"/",bqa.ovr,sep="")
mtl = paste(img,"_MTL.txt",sep="")
mtlpath = paste(ipath,img,"/",mtl,sep="")
download.file(bqapath , file.path(destfile,bqa))
download.file(bqaovrpath, file.path(destfile,bqa.ovr))
download.file(mtlpath, file.path(destfile,mtl))


###########################

#library(devtools)
#install_url("https://github.com/Terradue/rLandsat8/releases/download/v0.1-SNAPSHOT/rLandsat8_0.1.0.tar.gz")           #R 3.2
library(rLandsat8)
library(rgdal)
bnd = readOGR(".", "Boundaries")
newprj =projection(bnd)

l = ReadLandsat8(img)
btemp = ToAtSatelliteBrightnessTemperature(l, band="tirs1")
gc(F)
ndvi = ToNDVI(l)
gc(F)
pv = ((ndvi-0.2) / (0.5 -  0.2)) ^2
gc(F)
e = 0.004*pv+0.986
gc(F)

ldb10=((10.60 + 11.19)/ 2) /1000000
st = btemp / (1 + (ldb10*  btemp/0.01438) * log(e, exp(1)))
st = st - 273

st=crop(st, extent(bnd))
ndvi= crop(ndvi, extent(bnd))
st = projectRaster(st, crs=newprj)
ndvi = projectRaster(ndvi, crs=newprj)
lst=mask(st, bnd)
ndvi=mask(ndvi, bnd)


writeRaster(lst, paste(img,"/lst_",img,".asc",sep=""), format="ascii")
gc(F)
writeRaster(ndvi, paste(img,"/ndvi_",img,".asc",sep=""), format="ascii")
gc(F)
}
