use ExtUtils::MakeMaker;

WriteMakefile(
        NAME => "Bit::Set",
        VERSION_FROM => "lib/Bit/Set/OO.pm",
        ABSTRACT_FROM => "lib/Bit/Set/OO.pm",
        MIN_PERL_VERSION => "5.38.0",
        LIBS => '-L../Bit/build -lbit',
        PREREQ_PM => {
          sealed => 'v8.7.0',
          FFI::Platypus => 'v0.0.0',
          Alien::Bit => 'v0.0.0'
        }
);
