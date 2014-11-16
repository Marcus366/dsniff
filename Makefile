#
# Makefile for dsniff
#
# Dug Song <dugsong@monkey.org>
#
# $Id: Makefile.in,v 1.41 2000/12/15 20:03:26 dugsong Exp $

srcdir          = .


install_prefix  =
prefix          = /usr/local
exec_prefix	= ${prefix}
libdir		= ${exec_prefix}/lib
sbindir         = ${exec_prefix}/sbin
mandir		= ${prefix}/share/man

CC	= gcc
CFLAGS	= -g -O2 -D_BSD_SOURCE -D_BSD_SOURCE -D__BSD_SOURCE -D__FAVOR_BSD -DHAVE_NET_ETHERNET_H -DDSNIFF_LIBDIR=\"$(libdir)/\"
LDFLAGS	= 

PCAPINC = -I/usr/local/include
PCAPLIB = -L/usr/local/lib -lpcap

LNETINC = -I/usr/local/include
LNETLIB = -L/usr/local/lib -lnet

NIDSINC	= -I/usr/local/include
NIDSLIB	= -L/usr/local/lib -lnids

DBINC	= -I/usr/local/BerkeleyDB.6.1/include
DBLIB	= -L/usr/local/BerkeleyDB.6.1/lib -ldb

SSLINC	= -I/usr/local/ssl/include
SSLLIB	= -L/usr/local/ssl/lib -lssl -lcrypto

X11INC	= 
X11LIB	=   -lSM -lICE -lXmu -lX11 

GTHREADLIB = -lgthread-2.0 -lglib-2.0

INCS	= -I. $(NIDSINC) $(PCAPINC) $(LNETINC) $(DBINC) $(SSLINC) $(X11INC) \
	  -I$(srcdir)/missing
LIBS	= -lnsl -lrpcsvc  -L$(srcdir) -lmissing

INSTALL	= /usr/bin/install -c
INSTALL_PROGRAM = ${INSTALL}
INSTALL_DATA	= ${INSTALL} -m 644

RANLIB	= ranlib

HDRS	= asn1.h base64.h buf.h decode.h hex.h magic.h options.h \
	  pathnames.h pcaputil.h record.h rpc.h tcp_raw.h trigger.h \
	  version.h vroot.h

SRCS	= asn1.c base64.c buf.c hex.c magic.c mount.c pcaputil.c rpc.c \
	  tcp_raw.c trigger.c record.c dsniff.c decode.c decode_aim.c \
	  decode_citrix.c decode_cvs.c decode_ftp.c decode_hex.c \
	  decode_http.c decode_icq.c decode_imap.c decode_irc.c \
	  decode_ldap.c decode_mmxp.c decode_mountd.c decode_napster.c \
	  decode_nntp.c decode_oracle.c decode_ospf.c decode_pcanywhere.c \
	  decode_pop.c decode_portmap.c decode_postgresql.c decode_pptp.c \
	  decode_rip.c decode_rlogin.c decode_smb.c decode_smtp.c \
	  decode_sniffer.c decode_snmp.c decode_socks.c decode_tds.c \
	  decode_telnet.c decode_vrrp.c decode_yp.c decode_x11.c

GEN	= mount.h mount.c nfs_prot.h nfs_prot.c

OBJS	= $(SRCS:.c=.o)

LIBOBJS	= dummy.o  ${LIBOBJDIR}strlcpy$U.o ${LIBOBJDIR}strlcat$U.o ${LIBOBJDIR}md5$U.o

PROGS	= arpspoof dnsspoof dsniff filesnarf macof mailsnarf msgsnarf \
	  sshmitm tcpkill tcpnice  urlsnarf webmitm webspy 

CONFIGS	= dsniff.magic dsniff.services dnsspoof.hosts

.c.o:
	$(CC) $(CFLAGS) $(INCS) -c $(srcdir)/$*.c

all: libmissing.a $(PROGS)

mount.c: mount.x
	rpcgen -h mount.x -o mount.h
	rpcgen -c mount.x -o mount.c

nfs_prot.c: nfs_prot.x
	rpcgen -h nfs_prot.x -o nfs_prot.h
	rpcgen -c nfs_prot.x -o nfs_prot.c

$(LIBOBJS):
	$(CC) $(CFLAGS) $(INCS) -c $(srcdir)/missing/$*.c

libmissing.a: $(LIBOBJS)
	ar -cr $@ $(LIBOBJS)
	$(RANLIB) $@

dsniff: $(HDRS) $(SRCS) $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(LIBS) $(NIDSLIB) $(PCAPLIB) $(LNETLIB) $(DBLIB) $(SSLLIB) $(GTHREADLIB)

arpspoof: arpspoof.o arp.o
	$(CC) $(LDFLAGS) -o $@ arpspoof.o arp.o $(LIBS) $(PCAPLIB) $(LNETLIB)

dnsspoof: dnsspoof.o pcaputil.o
	$(CC) $(LDFLAGS) -o $@ dnsspoof.o pcaputil.o $(LIBS) $(PCAPLIB) $(LNETLIB) -lresolv

filesnarf: nfs_prot.o filesnarf.o pcaputil.o rpc.o
	$(CC) $(LDFLAGS) -o $@ filesnarf.o nfs_prot.o pcaputil.o rpc.o $(LIBS) $(NIDSLIB) $(PCAPLIB) $(LNETLIB) $(GTHREADLIB)

macof: macof.o
	$(CC) $(LDFLAGS) -o $@ macof.o $(LIBS) $(PCAPLIB) $(LNETLIB)

mailsnarf: mailsnarf.o buf.o pcaputil.o
	$(CC) $(LDFLAGS) -o $@ mailsnarf.o buf.o pcaputil.o $(LIBS) $(NIDSLIB) $(PCAPLIB) $(LNETLIB) $(GTHREADLIB)

msgsnarf: msgsnarf.o buf.o pcaputil.o
	$(CC) $(LDFLAGS) -o $@ msgsnarf.o buf.o pcaputil.o $(LIBS) $(NIDSLIB) $(PCAPLIB) $(LNETLIB) $(GTHREADLIB)

sshmitm: sshmitm.o buf.o hex.o record.o ssh.o sshcrypto.o
	$(CC) $(LDFLAGS) -o $@ sshmitm.o buf.o hex.o record.o ssh.o sshcrypto.o $(LIBS) $(LNETLIB) $(DBLIB) $(SSLLIB) -ldl

tcpkill: tcpkill.o pcaputil.o
	$(CC) $(LDFLAGS) -o $@ tcpkill.o pcaputil.o $(LIBS) $(PCAPLIB) $(LNETLIB)

tcpnice: tcpnice.o pcaputil.o
	$(CC) $(LDFLAGS) -o $@ tcpnice.o pcaputil.o $(LIBS) $(PCAPLIB) $(LNETLIB)

tcphijack: tcphijack.o pcaputil.o
	$(CC) $(LDFLAGS) -o $@ tcphijack.o pcaputil.o $(LIBS) $(PCAPLIB) $(LNETLIB)

urlsnarf: urlsnarf.o base64.o buf.o pcaputil.o
	$(CC) $(LDFLAGS) -o $@ urlsnarf.o base64.o buf.o pcaputil.o $(LIBS) $(NIDSLIB) $(PCAPLIB) $(LNETLIB) $(GTHREADLIB)

webmitm: webmitm.o base64.o buf.o decode_http.o record.o
	$(CC) $(LDFLAGS) -o $@ webmitm.o base64.o buf.o decode_http.o record.o $(LIBS) $(LNETLIB) $(DBLIB) $(SSLLIB)

webspy: webspy.o base64.o buf.o remote.o
	$(CC) $(LDFLAGS) -o $@ webspy.o base64.o buf.o remote.o $(LIBS) $(NIDSLIB) $(PCAPLIB) $(LNETLIB) $(X11LIB)

install:
	test -d $(install_prefix)$(sbindir) || \
	   $(INSTALL) -d $(install_prefix)$(sbindir)
	for file in $(PROGS); do \
	   $(INSTALL_PROGRAM) -m 755 $$file $(install_prefix)$(sbindir); \
	done
	test -d $(install_prefix)$(libdir) || \
	   $(INSTALL) -d $(install_prefix)$(libdir)
	for file in $(CONFIGS); do \
	   $(INSTALL_DATA) $$file $(install_prefix)$(libdir); \
	done
	test -d $(install_prefix)$(mandir)/man8 || \
	   $(INSTALL) -d $(install_prefix)$(mandir)/man8
	for file in *.8; do \
	   $(INSTALL_DATA) $$file $(install_prefix)$(mandir)/man8; \
	done

clean:
	rm -f *.o *~ $(GEN) libmissing.a $(PROGS) webmitm.crt

distclean: clean
	rm -f Makefile config.h config.cache config.log config.status

# EOF
