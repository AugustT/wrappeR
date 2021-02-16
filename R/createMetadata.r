#' \code{createMetadata} - Create master metadata table from objectstore data
#' repository
#' 
#' @description This function create 
#'
#' @param file_location Path to root directory of occupancy models on object
#'  store
#' 
#' @return Dataframe of metadata
#' 
#' @import dplyr
#' @import pbapply
#' @import stringr
#'         
#' @export

createMetadata <- function(file_location){

  metadata <- lapply(list.files(file_location), function(taxa){
    cat('Creating metadata for',taxa,'\n')
    data_types <- c("input_data", "occmod_outputs")
    ds <- pblapply(data_types, FUN = function(data_type){
      datasets <- list.files(file.path(file_location, taxa, data_type))
      years <- str_extract(string = datasets, pattern = '[0-9]+') %>% as.numeric()
      tryCatch(data.frame(taxa = taxa,
                          data_type = data_type,
                          data_location = file.path(file_location, taxa, data_type, datasets),
                          dataset_name = datasets,
                          most_recent = (years==max(years)), 
                          stringsAsFactors = FALSE),
               error=function(e) NULL)
    }) %>% bind_rows()
  }) %>% bind_rows()
  
  return(metadata)
}
