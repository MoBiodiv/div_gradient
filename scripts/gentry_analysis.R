source('./mobr/R/mobr.R')
source('./mobr/R/mobr_boxplots.R')

gentry = read.csv('./data/filtered_data/gentry.csv')

# enforce a minimum number of individuals per site
min_N = 120

N = tapply(gentry$count, list(gentry$site_id), sum)
gentry = gentry[as.character(gentry$site_id) %in% names(N[N > min_N]), ] 

site_line = paste(gentry$site_id, gentry$line, sep='_')
gentry_comm = tapply(gentry$count, 
                     list(site_line, gentry$species_id),
                     sum)
gentry_comm = ifelse(is.na(gentry_comm), 0, gentry_comm)

row_indices = match(row.names(gentry_comm), site_line)
gentry_env = gentry[row_indices, 
                    c('site_id', 'line', 'country', 'continent',
                      'lon', 'lat', 'min_elev', 'max_elev',
                      'precip')]
row.names(gentry_env) = paste(gentry_env$site_id, gentry_env$line, sep='_')

gentry_env$abslat = abs(gentry_env$lat)

gentry_comm = make_comm_obj(gentry_comm, gentry_env) 

gentry_tst = get_delta_stats(gentry_comm, env_var='abslat', group_var='site_id',  
                             type='continuous', log_scale=T, inds=10, nperm=1000) 
                              
save(gentry_tst, file='./results/gentry.tst.Rdata')

load('./results/gentry_tst_100.Rdata')

pdf('./figs/gentry_plots.pdf')

#plotSADs(comm, 'abslat')
#boxplot(gentry_comm)
plot(gentry_comm$env$abslat, rowSums(gentry_comm$comm >0))
plot(gentry_comm$env$abslat, rowSums(gentry_comm$comm))
#plotSNpie(comm, 'abslat')
#plot_rarefy(gentry_tst)
plot(gentry_tst)
dev.off()


