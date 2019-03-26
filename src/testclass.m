classdef testclass
properties
    info
end

methods
    function test = testclass(datadir)
        test.info = dir(datadir);
    end
end
end