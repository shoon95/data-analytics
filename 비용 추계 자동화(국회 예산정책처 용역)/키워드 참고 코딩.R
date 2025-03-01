install.packages('pacman')
library(pacman)

p_load('dplyr','openxlsx','stringr',data.table,tidyr)

dir.create('박사님')

setwd('C:/Users/sjhty/Desktop/용역')
list.files()


openxlsx::getSheetNames('키워드 원본.xlsx')

na<-getSheetNames('키워드 원본.xlsx')
#i<-'교재'
#j<-2
for(i in 1:12){
  data<-read.xlsx('키워드 원본.xlsx',sheet=i)
  assign(na[[i]],data)
}

load('r.Rdata')
교재비<-교재
na[[1]]<-'교재비'

lis<-mget(na)
name<-c('제목','전체 내용','값 존재 여부','연도','키워드','핵심 내용')

for(i in na){
  print(i)
  word<-paste0('(?=.*원)(?=.',i,').*')
  value<-sapply(lis[[i]][,2], function(x){grepl(word,x,perl=TRUE)})
  lis[[i]][,3]<-value
  lis[[i]]<-filter(lis[[i]],V3==TRUE)
  
  year<-sapply(lis[[i]][,1], function(x)if(grepl('2020 예산|2020예산',x)){2020}
            else if(grepl('2019 예산|2019예산',x)){2019}
            else if(grepl('2018 예산|2018예산',x)){2018}
            else if(grepl('2017 예산|2017예산',x)){2017}
            else if(grepl('2016 예산|2016예산',x)){2016})
  lis[[i]][,4]<-year
  lis[[i]][,5]<-i
  

  assign(i,lis[[i]])
}

 aaa<-data.frame()

lis<-mget(na)

for(i in na){     
   
  aaa<-data.frame()
  
  for(j in 1: nrow(lis[[i]])){
  t<-data.frame(str_split(lis[[i]][j,2],'\n'))
  t[,2]<-sapply(t, function(x) str_detect(x,i))
  text<-filter(t,V2==TRUE)
  a<-data.frame(text[,1])
  a<-t(a)
  names(a)<-1:nrow(text)
  aaa<-bind_rows(aaa,a)
  }
  
  lis[[i]][,6]<-unite(aaa,'핵심 내용',colnames(aaa),sep='|')
  word<-paste0('(?=.*[0-9])(?=.원).*')
  value<-sapply(lis[[i]][,6], function(x){grepl(word,x,perl=TRUE)})
  lis[[i]][,3]<-value
  lis[[i]]<-filter(lis[[i]],V3==TRUE)
  value<-sapply(lis[[i]][,6], function(x){str_replace_all(x,'\\|NA','')})
  lis[[i]][,6]<-value
  
  
  assign(i,lis[[i]])

}

all_data<-rbind(`R&D`,강사료,공기청정기,공청회,교재비,마스크,배상금,보상금,연수,인증,토론회,포상금)
word2<-'.*[0-9가-힣]+( ?[x×] ?)[0-9가-힣]+.*'

a<-sapply(all_data[,6], function(x) str_extract(x,word2))
b<-data.frame(a)

all_data[,7]<-b

all_data_end<-na.omit(all_data)
table(all_data_end[,5])



key<-createWorkbook()
addWorksheet(key,'키워드')
writeDataTable(key, '키워드',all_data_end)
saveWorkbook(key,'키워드 정리 수정.xlsx',overwrite=TRUE)


