# script to pull funder normalization data that will still need to be merged
# start with grabbing articles containing Wellcome Trust name variations in the funding statement
# variations include: Wellcome, Wellcome Trust, Welcome
# pull variations that we will exclude: Burroughs Welcome

library(rplos)
# search for Welcome or Welcome, exclude Burroughs and webpages
search_string <- '(Wellcome OR Welcome) NOT Burroughs NOT "/welcome"'
terms <- paste('financial_disclosure:', search_string)
response <- searchplos(terms=terms, fields='id,title,publication_date,financial_disclosure', toquery='doc_type:full', limit=10000)
write.csv(response, file="WellcomeWelcomeNotBurroughs.csv")

## OTHER SEARCHES
# search for Wellcome Trust
out <- searchplos(terms='financial_disclosure:"Wellcome Trust"', fields=c("financial_disclosure","id"), limit=4000)
write.csv(out, file="WellcomeTrust.csv")

# search for Wellcome
out2 <- searchplos(terms='financial_disclosure:"Wellcome"', fields=c("financial_disclosure","id"), limit=4000)
write.csv(out2, file="Wellcome.csv")

# search for Welcome Trust
out3 <- searchplos(terms='financial_disclosure:"Welcome Trust"', fields=c("financial_disclosure","id"), limit=4000)
write.csv(out3, file="WelcomeTrust.csv")

# search for Welcome
out4 <- searchplos(terms='financial_disclosure:"Welcome"', fields=c("financial_disclosure","id"), limit=4000)
write.csv(out4, file="Welcome.csv")

# search for Burroughs to exclude
out6 <- searchplos(terms='financial_disclosure:"Burroughs"', fields=c("financial_disclosure","id"), limit=4000)
write.csv(out6, file="Burroughs.csv")

# search for Wellcome exclude Burroughs
search_string <- 'Wellcome NOT Burroughs'
terms <- paste('financial_disclosure:', search_string)
response <- searchplos(terms=terms, fields='id,title,publication_date,financial_disclosure', toquery='doc_type:full', limit=10000)
write.csv(response, file="Burroughs.csv")

