{
  Conversion of /usr/include/asm-generic/ioctl.h

  1.0    - 2019.04.24 - Nicola Perotto <nicola@nicolaperotto.it>
}
{$I+,R+,Q+,H+}
{$IFDEF FPC}{$MODE DELPHI}{$ENDIF}
Unit IOCtl;

Interface


Const
  _IOC_NRBITS	    =  8;
  _IOC_TYPEBITS	  =  8;
  _IOC_SIZEBITS	  = 14;
  _IOC_DIRBITS	  =  2;

  _IOC_NRMASK	    = (1 shl _IOC_NRBITS)   -1;
  _IOC_TYPEMASK	  = (1 shl _IOC_TYPEBITS) -1;
  _IOC_SIZEMASK	  = (1 shl _IOC_SIZEBITS) -1;
  _IOC_DIRMASK	  = (1 shl _IOC_DIRBITS)  -1;

  _IOC_NRSHIFT	  = 0;
  _IOC_TYPESHIFT	= _IOC_NRSHIFT + _IOC_NRBITS;
  _IOC_SIZESHIFT	= _IOC_TYPESHIFT + _IOC_TYPEBITS;
  _IOC_DIRSHIFT	  = _IOC_SIZESHIFT + _IOC_SIZEBITS;

  _IOC_NONE	      = 0; //U
  _IOC_WRITE	    = 1; //U
  _IOC_READ	      = 2; //U

//You have to do it manually because Pascal lacks the C Pre-Processor!
//the constant generated is 32 bits
{
_IOC(dir, type, nr, size) := (dir shl _IOC_DIRSHIFT) or (type shl _IOC_TYPESHIFT) or (nr shl _IOC_NRSHIFT) or (size shl _IOC_SIZESHIFT);

_IO(type, nr)             := _IOC(_IOC_NONE,               type, nr, 0);
_IOR(type, nr, size)      := _IOC(_IOC_READ,               type, nr, size);
_IOW(type, nr, size)      := _IOC(_IOC_WRITE,              type, nr, size);
_IOWR(type, nr, size)     := _IOC(_IOC_READ or _IOC_WRITE, type, nr, size);
_IOR_BAD(type, nr, size)  := _IOC(_IOC_READ,               type, nr, sizeof(size));
_IOW_BAD(type, nr, size)  := _IOC(_IOC_WRITE,              type, nr, sizeof(size));
_IOWR_BAD(type, nr, size) := _IOC(_IOC_READ or _IOC_WRITE, type, nr, sizeof(size));
}

//* used to decode ioctl numbers.. */
//_IOC_DIR(nr)		  := (((nr) shr _IOC_DIRSHIFT)  and _IOC_DIRMASK);
//_IOC_TYPE(nr)		  := (((nr) shr _IOC_TYPESHIFT) and _IOC_TYPEMASK);
//_IOC_NR(nr)		    := (((nr) shr _IOC_NRSHIFT)   and _IOC_NRMASK);
//_IOC_SIZE(nr)		  := (((nr) shr _IOC_SIZESHIFT) and _IOC_SIZEMASK);

//* ...and for the drivers/sound files... */
Const
  IOC_IN		    = _IOC_WRITE shl _IOC_DIRSHIFT;
  IOC_OUT		    = _IOC_READ shl _IOC_DIRSHIFT;
  IOC_INOUT	    = (_IOC_WRITE or _IOC_READ) shl _IOC_DIRSHIFT;
  IOCSIZE_MASK	= _IOC_SIZEMASK or _IOC_SIZESHIFT;
  IOCSIZE_SHIFT	= _IOC_SIZESHIFT;

//example:
//#define EVIOCGVERSION		_IOR('E', 0x01, int)			/* get driver version */
//  EVIOCGVERSION     = (_IOC_READ shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or (1 shl _IOC_NRSHIFT) or (SizeOf(Integer) shl _IOC_SIZESHIFT);


Type //this is to check the parameters at compile time and skip at runtime!
  EIOCTLDir     = 0..(1 shl _IOC_DIRBITS) -1;
  EIOCTLType    = 0..(1 shl _IOC_TYPEBITS) -1;
  EIOCTLNumber  = 0..(1 shl _IOC_NRBITS) -1;
  EIOCTLSize    = 0..(1 shl _IOC_SIZEBITS) -1;

//TIOCtlRequest = cInt;
Function Compose_IOC(Const aDir:EIOCTLDir; Const aType:EIOCTLType; Const aNumber:EIOCTLNumber; Const aSize:EIOCTLSize):Integer;


Implementation


Function Compose_IOC(Const aDir:EIOCTLDir; Const aType:EIOCTLType; Const aNumber:EIOCTLNumber; Const aSize:EIOCTLSize):Integer;
begin //uses typecast because of range
  Result := Integer((aDir shl _IOC_DIRSHIFT) or (aType shl _IOC_TYPESHIFT) or (aNumber shl _IOC_NRSHIFT) or (aSize shl _IOC_SIZESHIFT));
end; //Compose_IOC

end.
