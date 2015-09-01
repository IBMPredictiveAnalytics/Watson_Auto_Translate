
# Watson Auto Translate
#
# Extension for IBM SPSS Modeler


# Install function for packages    
packages <- function(x){
  x <- as.character(match.call()[[2]])
  if (!require(x,character.only=TRUE)){
    install.packages(pkgs=x,repos="http://cran.r-project.org")
    require(x,character.only=TRUE)
  }
}

packages(httr)
packages(XML)

data <- data.frame() #Data frame to be populated with results
version <- R.Version()$major  #find R version for Post call
print(version)

for(i in 1:nrow(modelerData)) {
  text<-modelerData$%%text%%[i] #Load text 
  u <- "%%user%%"   #Username and Password provided in CDB
  p <- "%%password%%"
  base <- "https://gateway.watsonplatform.net/language-translation/api/v2/identify" #URL to ID the language
  pars <- list(txt=iconv(text,to="UTF-8")) #parameters for body of POST
  if (version == 2){
    r<-POST(base,authenticate(u, p), body = pars)
  }else{
    r<-POST(base,authenticate(u, p),add_headers(Accept = "text/plain"), body = pars)
  }
  stop_for_status(r)
  source_language <-content(r) #Determined with first API Call   
  target_language = %%target%%
    
    #Check to see the translation being requested - current version of API reuires english as source or target
    if (source_language == target_language) {text<-as.character(modelerData$%%text%%[i])}
  else if (!(is.element("en", c(source_language, target_language)))){
    text<-"Unable to convert non-english to non-english at this time" }
  else if(source_language != target_language) {
    base <- "https://gateway.watsonplatform.net/language-translation/api/v2/translate?source=" #URL to translate to target        
    full_url <- paste(base,source_language,"&target=", target_language, sep = '')
    pars <- list(txt=iconv(text,to="UTF-8")) #parameters for body of POST     
    if (version == 2){
      r<-POST(full_url,authenticate(u, p), body = pars)
    } else{
      r<-POST(full_url,authenticate(u, p),add_headers(Accept = "text/plain"), body = pars)
    }
    stop_for_status(r)
    text<-content(r)
    
  }
  
  data[i,1] <- source_language    #Updating output dataframe with results from API
  data[i,2] <- text
}

colnames(data)<-c("Source Language ID","Translated Text")

#Build Modeler Data Model
modelerData<-cbind(modelerData,c(data[1]))
var1<-c(fieldName="Source Language ID",fieldLabel="",fieldStorage="string",fieldFormat="",fieldMeasure="",  fieldRole="")
modelerDataModel<-data.frame(modelerDataModel,var1)

modelerData<-cbind(modelerData,c(data[2]))
var2<-c(fieldName="Translated Text",fieldLabel="",fieldStorage="string",fieldFormat="",fieldMeasure="",  fieldRole="")
modelerDataModel<-data.frame(modelerDataModel,var2)

