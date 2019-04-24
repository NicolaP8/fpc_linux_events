{
  Conversion from Linux Kernel input.h 

  1.0    - 2019.04.24 - Nicola Perotto <nicola@nicolaperotto.it>
}
{
https://github.com/torvalds/linux/blob/master/include/uapi/linux/input.h

/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
/*
 * Copyright (c) 1999-2002 Vojtech Pavlik
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 as published by
 * the Free Software Foundation.
}

{$I+,R+,Q+}
{$IFDEF FPC}{$MODE DELPHI}{$ENDIF}
Unit Input;

Interface


Uses
  {$IFDEF FPC}BaseUnix, {$ENDIF}  IOCtl;

{$IFNDEF FPC}//Syntax Check in Delphi IDE
Type
  cInt = integer;
  TIOCtlRequest = cInt;
  QWord = Int64;
  clong = LongInt;
{$ENDIF}

Type
  time_t = clong; 
  timeval = record
    tv_sec : time_t;
    tv_usec : clong;
  end;

Const
  //Protocol version.
  EV_VERSION		          = $010001;
  EV_SYN                  = 0;
  INPUT_KEYMAP_BY_INDEX	  = (1 shl 0);
  NUM_SLOTS               = 8;

Const
  //IDs
  ID_BUS			      =  0;
  ID_VENDOR		      =  1;
  ID_PRODUCT		    =  2;
  ID_VERSION		    =  3;

  BUS_PCI			      = $01;
  BUS_ISAPNP		    = $02;
  BUS_USB			      = $03;
  BUS_HIL			      = $04;
  BUS_BLUETOOTH		  = $05;
  BUS_VIRTUAL		    = $06;

  BUS_ISA			      = $10;
  BUS_I8042		      = $11;
  BUS_XTKBD		      = $12;
  BUS_RS232		      = $13;
  BUS_GAMEPORT		  = $14;
  BUS_PARPORT		    = $15;
  BUS_AMIGA		      = $16;
  BUS_ADB			      = $17;
  BUS_I2C			      = $18;
  BUS_HOST		      = $19;
  BUS_GSC			      = $1A;
  BUS_ATARI		      = $1B;
  BUS_SPI			      = $1C;
  BUS_RMI			      = $1D;
  BUS_CEC			      = $1E;
  BUS_INTEL_ISHTP		= $1F;

  //MT_TOOL types
  MT_TOOL_FINGER		= $00;
  MT_TOOL_PEN		    = $01;
  MT_TOOL_PALM		  = $02;
  MT_TOOL_DIAL		  = $0a;
  MT_TOOL_MAX		    = $0f;

  //Values describing the status of a force-feedback effect
  FF_STATUS_STOPPED	= $00;
  FF_STATUS_PLAYING	= $01;
  FF_STATUS_MAX		  = $01;

Const
  //Force feedback effect types
  FF_RUMBLE	        = $50;
  FF_PERIODIC	      = $51;
  FF_CONSTANT	      = $52;
  FF_SPRING	        = $53;
  FF_FRICTION	      = $54;
  FF_DAMPER	        = $55;
  FF_INERTIA	      = $56;
  FF_RAMP		        = $57;

  FF_EFFECT_MIN	    = FF_RUMBLE;
  FF_EFFECT_MAX	    = FF_RAMP;

  //Force feedback periodic effect types
  FF_SQUARE	        = $58;
  FF_TRIANGLE	      = $59;
  FF_SINE		        = $5a;
  FF_SAW_UP	        = $5b;
  FF_SAW_DOWN	      = $5c;
  FF_CUSTOM	        = $5d;

  FF_WAVEFORM_MIN	  = FF_SQUARE;
  FF_WAVEFORM_MAX	  = FF_CUSTOM;

  //Set ff device properties
  FF_GAIN		        = $60;
  FF_AUTOCENTER	    = $61;

  {
   * ff->playback(effect_id = FF_GAIN) is the first effect_id to
   * cause a collision with another ff method, in this case ff->set_gain().
   * Therefore the greatest safe value for effect_id is FF_GAIN - 1,
   * and thus the total number of effects should never exceed FF_GAIN.
  }
  FF_MAX_EFFECTS	  = FF_GAIN;

  FF_MAX		        = $7f;
  FF_CNT		        = (FF_MAX+1);


Type
{ * The event structure itself
 * Note that __USE_TIME_BITS64 is defined by libc based on
 * application's request to use 64 bit time_t.}
  TInput_Event = packed record
    Time : timeval;
    etype : Word;
    code : Word;
    value : LongInt;
  end;

  TInput_ID = packed record
	  bustype,
	  vendor,
	  product,
	  version : Word
  end;

{
 * struct input_absinfo - used by EVIOCGABS/EVIOCSABS ioctls
 * @value: latest reported value for the axis.
 * @minimum: specifies minimum value for the axis.
 * @maximum: specifies maximum value for the axis.
 * @fuzz: specifies fuzz value that is used to filter noise from
 *	the event stream.
 * @flat: values that are within this value will be discarded by
 *	joydev interface and reported as 0 instead.
 * @resolution: specifies resolution for the values reported for
 *	the axis.
 *
 * Note that input core does not clamp reported values to the
 * [minimum, maximum] limits, such task is left to userspace.
 *
 * The default resolution for main axes (ABS_X, ABS_Y, ABS_Z)
 * is reported in units per millimeter (units/mm), resolution
 * for rotational axes (ABS_RX, ABS_RY, ABS_RZ) is reported
 * in units per radian.
 * When INPUT_PROP_ACCELEROMETER is set the resolution changes.
 * The main axes (ABS_X, ABS_Y, ABS_Z) are then reported in
 * in units per g (units/g) and in units per degree per second
 * (units/deg/s) for rotational axes (ABS_RX, ABS_RY, ABS_RZ).
}
  TInput_Absinfo = packed record
	  value : LongInt;
	  minimum : LongInt;
	  maximum : LongInt;
    fuzz : LongInt;
    flat : LongInt;
    resolution : LongInt;
  end;

{
 * struct input_keymap_entry - used by EVIOCGKEYCODE/EVIOCSKEYCODE ioctls
 * @scancode: scancode represented in machine-endian form.
 * @len: length of the scancode that resides in @scancode buffer.
 * @index: index in the keymap, may be used instead of scancode
 * @flags: allows to specify how kernel should handle the request. For
 *	example, setting INPUT_KEYMAP_BY_INDEX flag indicates that kernel
 *	should perform lookup in keymap by @index instead of @scancode
 * @keycode: key code assigned to this scancode
 *
 * The structure is used to retrieve and modify keymap data. Users have
 * option of performing lookup either by @scancode itself or by @index
 * in keymap entry. EVIOCGKEYCODE will also return scancode or index
 * (depending on which element was used to perform lookup).
}
  TInput_Keymap_Entry = packed record
	  flags : byte;
	  len : byte;
	  index : word;
	  keycode : LongWord;
	  scancode : array[0..31] of byte;
  end;

  TInput_Mask = packed record
    etype : LongWord;
    codes_size : LongWord;
    codes_ptr : QWord;
  end;

  TInput_My_Request_Layout = packed record
    code : LongWord;
    values : array[0..NUM_SLOTS -1] of LongInt;
  end;

  {
   * Structures used in ioctls to upload effects to a device
   * They are pieces of a bigger structure (called ff_effect)

   * All duration values are expressed in ms. Values above 32767 ms (0x7fff)
   * should not be used and have unspecified results.
  }

  {
   * struct ff_replay - defines scheduling of the force-feedback effect
   * @length: duration of the effect
   * @delay: delay before effect should start playing
  }
  TFF_Replay = packed record
    length : word;
	  delay : word;
  end;

  {
   * struct ff_trigger - defines what triggers the force-feedback effect
   * @button: number of the button triggering the effect
   * @interval: controls how soon the effect can be re-triggered
  }
  TFF_Trigger = packed record
	  button : word;
    interval : word;
  end;

  {
   * struct ff_envelope - generic force-feedback effect envelope
   * @attack_length: duration of the attack (ms)
   * @attack_level: level at the beginning of the attack
   * @fade_length: duration of fade (ms)
   * @fade_level: level at the end of fade
   *
   * The @attack_level and @fade_level are absolute values; when applying
   * envelope force-feedback core will convert to positive/negative
   * value based on polarity of the default level of the effect.
   * Valid range for the attack and fade levels is 0x0000 - 0x7fff
  }
  TFF_Envelope = packed record
	  attack_length : word;
	  attack_level : word;
	  fade_length : word;
  	fade_level : word;
  end;

  {
   * struct ff_constant_effect - defines parameters of a constant force-feedback effect
   * @level: strength of the effect; may be negative
   * @envelope: envelope data
  }
  TFF_Constant_Effect = packed record
    level : Smallint;
    envelope : TFF_Envelope;
  end;

  {
   * struct ff_ramp_effect - defines parameters of a ramp force-feedback effect
   * @start_level: beginning strength of the effect; may be negative
   * @end_level: final strength of the effect; may be negative
   * @envelope: envelope data
  }
  TFF_Ramp_Effect = packed record
	  start_level : Smallint;
	  end_level : Smallint;
    envelope : TFF_Envelope;
  end;

  {
   * struct ff_condition_effect - defines a spring or friction force-feedback effect
   * @right_saturation: maximum level when joystick moved all way to the right
   * @left_saturation: same for the left side
   * @right_coeff: controls how fast the force grows when the joystick moves
   *	to the right
   * @left_coeff: same for the left side
   * @deadband: size of the dead zone, where no force is produced
   * @center: position of the dead zone
  }
  TFF_Condition_Effect = packed record
	  right_saturation : word;
	  left_saturation : word;

	  right_coeff : Smallint;
	  left_coeff : Smallint;

	  deadband : word;
	  center : Smallint;
  end;

  {
   * struct ff_periodic_effect - defines parameters of a periodic force-feedback effect
   * @waveform: kind of the effect (wave)
   * @period: period of the wave (ms)
   * @magnitude: peak value
   * @offset: mean value of the wave (roughly)
   * @phase: 'horizontal' shift
   * @envelope: envelope data
   * @custom_len: number of samples (FF_CUSTOM only)
   * @custom_data: buffer of samples (FF_CUSTOM only)
   *
   * Known waveforms - FF_SQUARE, FF_TRIANGLE, FF_SINE, FF_SAW_UP,
   * FF_SAW_DOWN, FF_CUSTOM. The exact syntax FF_CUSTOM is undefined
   * for the time being as no driver supports it yet.
   *
   * Note: the data pointed by custom_data is copied by the driver.
   * You can therefore dispose of the memory after the upload/update.
  }
  TFF_Periodic_Effect = packed record
	  waveform : word;
	  period : word;
	  magnitude : SmallInt;
	  offset : SmallInt;
	  phase : word;

    envelope : TFF_Envelope;

  	custom_len : LongWord;
	  custom_data : Pointer; //to SmallInt / __s16 
  end;

  {
   * struct ff_rumble_effect - defines parameters of a periodic force-feedback effect
   * @strong_magnitude: magnitude of the heavy motor
   * @weak_magnitude: magnitude of the light one
   *
   * Some rumble pads have two motors of different weight. Strong_magnitude
   * represents the magnitude of the vibration generated by the heavy one.
  }
  TFF_Rumble_Effect = packed record
	  strong_magnitude : word;
	  weak_magnitude : word;
  end;

  {
   * struct ff_effect - defines force feedback effect
   * @type: type of the effect (FF_CONSTANT, FF_PERIODIC, FF_RAMP, FF_SPRING,
   *	FF_FRICTION, FF_DAMPER, FF_RUMBLE, FF_INERTIA, or FF_CUSTOM)
   * @id: an unique id assigned to an effect
   * @direction: direction of the effect
   * @trigger: trigger conditions (struct ff_trigger)
   * @replay: scheduling of the effect (struct ff_replay)
   * @u: effect-specific structure (one of ff_constant_effect, ff_ramp_effect,
   *	ff_periodic_effect, ff_condition_effect, ff_rumble_effect) further
   *	defining effect parameters
   *
   * This structure is sent through ioctl from the application to the driver.
   * To create a new effect application should set its @id to -1; the kernel
   * will return assigned @id which can later be used to update or delete
   * this effect.
   *
   * Direction of the effect is encoded as follows:
   *	0 deg -> 0x0000 (down)
   *	90 deg -> 0x4000 (left)
   *	180 deg -> 0x8000 (up)
   *	270 deg -> 0xC000 (right)
  }
  TFF_Effect = packed record
	  etype : word;
	  id : SmallInt;
	  direction : word;
    trigger : TFF_Trigger;
    replay : TFF_Replay;

    //union u
		constant : TFF_Constant_Effect;
		ramp : TFF_Ramp_Effect;
		periodic : TFF_Periodic_Effect;
		condition : array[0..1] of TFF_Condition_Effect ; //One for each axis 
		rumble : TFF_Rumble_Effect; 
  end;


Const
//#define EVIOCGVERSION		_IOR('E', 0x01, int)			/* get driver version */
  EVIOCGVERSION     = (_IOC_READ shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($01 shl _IOC_NRSHIFT) or (SizeOf(LongInt) shl _IOC_SIZESHIFT);

//#define EVIOCGID		_IOR('E', 0x02, struct input_id)	/* get device ID */
  EVIOCGID          = (_IOC_READ shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($02 shl _IOC_NRSHIFT) or (SizeOf(TInput_ID) shl _IOC_SIZESHIFT);

//#define EVIOCGREP		_IOR('E', 0x03, unsigned int[2])	/* get repeat settings */
  EVIOCGREP         = (_IOC_READ shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($03 shl _IOC_NRSHIFT) or ((2*SizeOf(LongWord)) shl _IOC_SIZESHIFT);

//#define EVIOCSREP		_IOW('E', 0x03, unsigned int[2])	/* set repeat settings */
  EVIOCSREP         = (_IOC_WRITE shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($03 shl _IOC_NRSHIFT) or ((2*SizeOf(LongWord)) shl _IOC_SIZESHIFT);

//#define EVIOCGKEYCODE		_IOR('E', 0x04, unsigned int[2])        /* get keycode */
  EVIOCGKEYCODE     = (_IOC_READ shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($04 shl _IOC_NRSHIFT) or ((2*SizeOf(LongWord)) shl _IOC_SIZESHIFT);
//#define EVIOCGKEYCODE_V2	_IOR('E', 0x04, struct input_keymap_entry)
  EVIOCGKEYCODE_V2  = (_IOC_READ shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($04 shl _IOC_NRSHIFT) or (SizeOf(Tinput_keymap_entry) shl _IOC_SIZESHIFT);
//#define EVIOCSKEYCODE		_IOW('E', 0x04, unsigned int[2])        /* set keycode */
  EVIOCSKEYCODE     = (_IOC_WRITE shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($04 shl _IOC_NRSHIFT) or ((2*SizeOf(LongWord)) shl _IOC_SIZESHIFT);
//#define EVIOCSKEYCODE_V2	_IOW('E', 0x04, struct input_keymap_entry)
  EVIOCSKEYCODE_V2  = (_IOC_WRITE shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($04 shl _IOC_NRSHIFT) or (SizeOf(Tinput_keymap_entry) shl _IOC_SIZESHIFT);

//these return a string (c, #0 terminated) so len is fixed (by me) at 256  
//#define EVIOCGNAME(len)		_IOC(_IOC_READ, 'E', 0x06, len)		/* get device name */
  EVIOCGNAME_size   = 256;
  EVIOCGNAME        = (_IOC_READ shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($06 shl _IOC_NRSHIFT) or (EVIOCGNAME_size shl _IOC_SIZESHIFT);
//#define EVIOCGPHYS(len)		_IOC(_IOC_READ, 'E', 0x07, len)		/* get physical location */
  EVIOCGPHYS_size   = 256;
  EVIOCGPHYS        = (_IOC_READ shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($07 shl _IOC_NRSHIFT) or (EVIOCGPHYS_size shl _IOC_SIZESHIFT);
//#define EVIOCGUNIQ(len)		_IOC(_IOC_READ, 'E', 0x08, len)		/* get unique identifier */
  EVIOCGUNIQ_size   = 256;
  EVIOCGUNIQ        = (_IOC_READ shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($08 shl _IOC_NRSHIFT) or (EVIOCGUNIQ_size shl _IOC_SIZESHIFT);
//#define EVIOCGPROP(len)		_IOC(_IOC_READ, 'E', 0x09, len)		/* get device properties */
  EVIOCGPROP_size   = 256;
  EVIOCGPROP        = (_IOC_READ shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($09 shl _IOC_NRSHIFT) or (EVIOCGPROP_size shl _IOC_SIZESHIFT);

{
 * EVIOCGMTSLOTS(len) - get MT slot values
 * @len: size of the data buffer in bytes
 *
 * The ioctl buffer argument should be binary equivalent to
 *
 * struct input_mt_request_layout {
 *	__u32 code;
 *	__s32 values[num_slots];
 *
 *
 * where num_slots is the (arbitrary) number of MT slots to extract.
 *
 * The ioctl size argument (len) is the size of the buffer, which
 * should satisfy len = (num_slots + 1) * sizeof(__s32).  If len is
 * too small to fit all available slots, the first num_slots are
 * returned.
 *
 * Before the call, code is set to the wanted ABS_MT event type. On
 * return, values[] is filled with the slot values for the specified
 * ABS_MT code.
 *
 * If the request code is not an ABS_MT value, -EINVAL is returned.
}
//#define EVIOCGMTSLOTS(len)	_IOC(_IOC_READ, 'E', 0x0a, len)
  EVIOCGMTSLOTS_len = SizeOf(TInput_My_Request_Layout);
  EVIOCGMTSLOTS     = (_IOC_READ shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($0a shl _IOC_NRSHIFT) or (EVIOCGMTSLOTS_len shl _IOC_SIZESHIFT);

//#define EVIOCGKEY(len)		_IOC(_IOC_READ, 'E', 0x18, len)		/* get global key state */
  EVIOCGKEY_len     = 16;
  EVIOCGKEY         = (_IOC_READ shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($18 shl _IOC_NRSHIFT) or (EVIOCGKEY_len shl _IOC_SIZESHIFT);
//#define EVIOCGLED(len)		_IOC(_IOC_READ, 'E', 0x19, len)		/* get all LEDs */
  EVIOCGLED_len     = 16;
  EVIOCGLED         = (_IOC_READ shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($19 shl _IOC_NRSHIFT) or (EVIOCGLED_len shl _IOC_SIZESHIFT);
//#define EVIOCGSND(len)		_IOC(_IOC_READ, 'E', 0x1a, len)		/* get all sounds status */
  EVIOCGSND_len     = 16;
  EVIOCGSND         = (_IOC_READ shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($1a shl _IOC_NRSHIFT) or (EVIOCGSND_len shl _IOC_SIZESHIFT);
//#define EVIOCGSW(len)		_IOC(_IOC_READ, 'E', 0x1b, len)		/* get all switch states */
  EVIOCGSW_len      = 16;
  EVIOCGSW          = (_IOC_READ shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($0b shl _IOC_NRSHIFT) or (EVIOCGSW_len shl _IOC_SIZESHIFT);

//#define EVIOCGBIT(ev,len)	_IOC(_IOC_READ, 'E', 0x20 + (ev), len)	/* get event bits */
//@@@ use Compose_IOC()
//ev = 0 -> return all
  EVIOCGBIT         = (_IOC_READ shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($20 shl _IOC_NRSHIFT) or (0 shl _IOC_SIZESHIFT);

//#define EVIOCGABS(abs)		_IOR('E', 0x40 + (abs), struct input_absinfo)	/* get abs value/limits */
  //@@@ abs
  EVIOCGABS         = (_IOC_READ shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($40 shl _IOC_NRSHIFT) or (SizeOf(TInput_Absinfo) shl _IOC_SIZESHIFT);

//#define EVIOCSABS(abs)		_IOW('E', 0xc0 + (abs), struct input_absinfo)	/* set abs value/limits */
  //@@@ abs
  EVIOCSABS         = (_IOC_WRITE shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($c0 shl _IOC_NRSHIFT) or (SizeOf(TInput_Absinfo) shl _IOC_SIZESHIFT);

//#define EVIOCSFF		_IOW('E', 0x80, struct ff_effect)	/* send a force effect to a force feedback device */
  EVIOCSFF          = (_IOC_WRITE shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($80 shl _IOC_NRSHIFT) or (SizeOf(TFF_Effect) shl _IOC_SIZESHIFT);
//#define EVIOCRMFF		_IOW('E', 0x81, int)			/* Erase a force effect */
  EVIOCRMFF         = (_IOC_WRITE shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($81 shl _IOC_NRSHIFT) or (SizeOf(LongInt) shl _IOC_SIZESHIFT);
//#define EVIOCGEFFECTS		_IOR('E', 0x84, int)			/* Report number of effects playable at the same time */
  EVIOCGEFFECTS     = (_IOC_READ shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($84 shl _IOC_NRSHIFT) or (SizeOf(LongInt) shl _IOC_SIZESHIFT);

//#define EVIOCGRAB		_IOW('E', 0x90, int)			/* Grab/Release device */
  EVIOCGRAB         = (_IOC_WRITE shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($90 shl _IOC_NRSHIFT) or (SizeOf(LongInt) shl _IOC_SIZESHIFT);
//#define EVIOCREVOKE		_IOW('E', 0x91, int)			/* Revoke device access */
  EVIOCREVOKE       = (_IOC_WRITE shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($91 shl _IOC_NRSHIFT) or (SizeOf(LongInt) shl _IOC_SIZESHIFT);

{
 * EVIOCGMASK - Retrieve current event mask
 *
 * This ioctl allows user to retrieve the current event mask for specific
 * event type. The argument must be of type "struct input_mask" and
 * specifies the event type to query, the address of the receive buffer and
 * the size of the receive buffer.
 *
 * The event mask is a per-client mask that specifies which events are
 * forwarded to the client. Each event code is represented by a single bit
 * in the event mask. If the bit is set, the event is passed to the client
 * normally. Otherwise, the event is filtered and will never be queued on
 * the client's receive buffer.
 *
 * Event masks do not affect global state of the input device. They only
 * affect the file descriptor they are applied to.
 *
 * The default event mask for a client has all bits set, i.e. all events
 * are forwarded to the client. If the kernel is queried for an unknown
 * event type or if the receive buffer is larger than the number of
 * event codes known to the kernel, the kernel returns all zeroes for those
 * codes.
 *
 * At maximum, codes_size bytes are copied.
 *
 * This ioctl may fail with ENODEV in case the file is revoked, EFAULT
 * if the receive-buffer points to invalid memory, or EINVAL if the kernel
 * does not implement the ioctl.
}
//#define EVIOCGMASK		_IOR('E', 0x92, struct input_mask)	/* Get event-masks */
  EVIOCGMASK        = (_IOC_READ shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($92 shl _IOC_NRSHIFT) or (SizeOf(TInput_Mask) shl _IOC_SIZESHIFT);

{
 * EVIOCSMASK - Set event mask
 *
 * This ioctl is the counterpart to EVIOCGMASK. Instead of receiving the
 * current event mask, this changes the client's event mask for a specific
 * type.  See EVIOCGMASK for a description of event-masks and the
 * argument-type.
 *
 * This ioctl provides full forward compatibility. If the passed event type
 * is unknown to the kernel, or if the number of event codes specified in
 * the mask is bigger than what is known to the kernel, the ioctl is still
 * accepted and applied. However, any unknown codes are left untouched and
 * stay cleared. That means, the kernel always filters unknown codes
 * regardless of what the client requests.  If the new mask doesn't cover
 * all known event-codes, all remaining codes are automatically cleared and
 * thus filtered.
 *
 * This ioctl may fail with ENODEV in case the file is revoked. EFAULT is
 * returned if the receive-buffer points to invalid memory. EINVAL is returned
 * if the kernel does not implement the ioctl.
}
//#define EVIOCSMASK		_IOW('E', 0x93, struct input_mask)	/* Set event-masks */
  EVIOCSMASK        = (_IOC_WRITE shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($93 shl _IOC_NRSHIFT) or (SizeOf(TInput_Mask) shl _IOC_SIZESHIFT);

//#define EVIOCSCLOCKID		_IOW('E', 0xa0, int)			/* Set clockid to be used for timestamps */
  EVIOCSCLOCKID     = (_IOC_WRITE shl _IOC_DIRSHIFT) or (Ord('E') shl _IOC_TYPESHIFT) or ($a0 shl _IOC_NRSHIFT) or (SizeOf(LongInt) shl _IOC_SIZESHIFT);


Implementation

end.
