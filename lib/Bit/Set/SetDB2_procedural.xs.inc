
MODULE = Bit::Set::DB2		PACKAGE = Bit::Set::DB2     PREFIX=BSDB2_

PROTOTYPES: DISABLE

# Functions that create, free, load from an external buffer


SV*
BSDB2_BitDB_new( IV length, IV num_of_bitsets)
    CODE:
        Bit_DB_T obj = BitDB_new((int)length,(int)num_of_bitsets);
    
        RETVAL = newSVuv(PTR2UV(obj));
    OUTPUT:
        RETVAL

void 
BSDB2_BitDB_free(SV* db_ref)
    CODE:
        if (!SvROK(db_ref)) {
            croak("BitDB_free expects a scalar reference");
        }
        SV *inner = SvRV(db_ref);
        Bit_DB_T db = INT2PTR(Bit_DB_T, SvIV(inner));
        BitDB_free(&db);

SV*
BSDB2_BitDB_load(IV length, IV num_of_bitsets, SV* buffer)
    CODE:
        void *ptr = SV_TO_VOID(buffer);
        Bit_DB_T db = BitDB_load((int)length, (int)num_of_bitsets, ptr);
        RETVAL = newSVuv(PTR2UV(db));
    OUTPUT:
        RETVAL

# Functions that obtain the properties of the Bit_DB_T
int 
BSDB2_BitDB_nelem(SV* db_ref)
    CODE:
        Bit_DB_T db = SV_TO_TYPE(Bit_DB_T, db_ref, UNDEF_DB_ERROR);
        RETVAL      = (IV)BitDB_nelem(db);
    OUTPUT:
        RETVAL

int
BSDB2_BitDB_length(SV* db_ref)
    CODE:
        Bit_DB_T db =  SV_TO_TYPE(Bit_DB_T,db_ref,UNDEF_DB_ERROR);
        RETVAL = (IV)BitDB_length(db);
    OUTPUT:
        RETVAL

int
BSDB2_BitDB_count_at(SV* db_ref, IV index)
    CODE:
        Bit_DB_T db = SV_TO_TYPE(Bit_DB_T,db_ref,UNDEF_DB_ERROR);
        RETVAL = (IV)BitDB_count_at(db,(int)index);
    OUTPUT:
        RETVAL