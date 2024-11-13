make clean_all
make compile
make run_cli GEN_TRANS_TYPE=generator
make run_cli GEN_TRANS_TYPE=generator_register_tests
make merge_coverage
make view_coverage
