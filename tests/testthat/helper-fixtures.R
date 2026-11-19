# Small synthetic DMP/DMR tables shaped like the outputs of filter_dmps() and find_dmrs().

fake_dmps <- function() {
  data.table::data.table(
    Contrast = c("A-B", "A-B", "A-B", "A-C"),
    Type = c("Hyper", "Hypo", "Hyper", "Hypo"),
    UCSC_RefGene_Name = c("G1;G1", "G2", "", "G3"),
    UCSC_RefGene_Group = c("TSS200;TSS200", "Body", "", "exon_1"),
    Relation_to_Island = c("Island", "Shore", "OpenSea", "Island")
  )
}

fake_dmrs <- function() {
  data.table::data.table(
    Contrast = c("A-B", "A-B"),
    meandiff = c(0.3, -0.2),
    overlapping.genes = c("G1,G4", "G2")
  )
}
