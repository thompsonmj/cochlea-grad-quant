function blankSection = initializesectionstruct

blankSection = struct( ...
    'age',                      [], ...
    'cochlea_idx',              [], ...
    'section_ab',               [], ...
    'section_idx',              [], ...
    ...
    'psmad',                    [], ...
    'sox2',                     [], ...
    'jag1',                     [], ...
    'bmp4_mrna',                [], ...
    'topro3',                   [], ...
    'length',                   [], ...
    ...
    'psmad_nuc',                [], ...
    'psmad_nuc_sem',            [], ...
    'sox2_nuc',                 [], ...
    'sox2_nuc_sem',             [], ...
    'topro3_nuc',               [], ...
    'topro3_nuc_sem',           [], ...
    'x_nuc',                    [], ...
    ...
    'flag',                     [], ...
    ...
    'pse_roi',                  [], ...
    'nuc_roi',                  [], ...
    ...
    'psmad_img_file',           [], ...
    'sox2_img_file',            [], ...
    'jag1_img_file',            [], ...
    'bmp4_mrna_img_file',       [], ...
    'topro3_img_file',          [], ...
    ...
    'img_scale',                [], ...
    'origional_bit_depth',      [], ...
    'origional_resolution',     [] );