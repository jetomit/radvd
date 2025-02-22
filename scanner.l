/*
 *
 *   Authors:
 *    Pedro Roque		<roque@di.fc.ul.pt>
 *    Lars Fenneberg		<lf@elemental.net>
 *
 *   This software is Copyright 1996-2000 by the above mentioned author(s),
 *   All Rights Reserved.
 *
 *   The license which is distributed with this software in the file COPYRIGHT
 *   applies to this software. If your distribution is missing this file, you
 *   may request it from <reubenhwk@gmail.com>.
 *
 */

%option nounput noinput noyywrap yylineno caseless

%{
#include "config.h"
#include "includes.h"
#include "log.h"
#include "gram.h"

int num_lines;

%}

digit		[0-9]
number		({digit})+
snum		-?({digit})+
decimal		({number}"."{number})
hexdigit	([a-f]|[A-F]|[0-9])
addr1		{hexdigit}{1,4}":"({hexdigit}{1,4}":")*(":"{hexdigit}{1,4})+
addr2		{hexdigit}{1,4}(":"{hexdigit}{1,4})*"::"
addr3		({hexdigit}{1,4}":"){7}{hexdigit}{1,4}
addr		({addr1}|{addr2}|{addr3}|"::")
naddr		("!"{addr})
whitespace	([ \t])+
string		[a-zA-Z0-9`~!@#$%\^&*()_\-+=:\[\]<>,\.?\\]+|L?\"(\\.|[^\\"])*\"
%%

#.*$			{/* ignore comments */}
\n			{num_lines++;}
{whitespace}		{}

interface		{ return T_INTERFACE; }
prefix			{ return T_PREFIX; }
route			{ return T_ROUTE; }
RDNSS			{ return T_RDNSS; }
DNSSL			{ return T_DNSSL; }
clients			{ return T_CLIENTS; }
lowpanco		{ return T_LOWPANCO; }
abro			{ return T_ABRO; }
nat64prefix		{ return T_NAT64PREFIX; }

AdvRASrcAddress	{ return T_RASRCADDRESS; }

IgnoreIfMissing		{ return T_IgnoreIfMissing; }
AdvSendAdvert		{ return T_AdvSendAdvert; }
MaxRtrAdvInterval	{ return T_MaxRtrAdvInterval; }
MinRtrAdvInterval	{ return T_MinRtrAdvInterval; }
AdvManagedFlag		{ return T_AdvManagedFlag; }
AdvOtherConfigFlag	{ return T_AdvOtherConfigFlag; }
AdvLinkMTU		{ return T_AdvLinkMTU; }
AdvRAMTU		{ return T_AdvRAMTU; }
AdvReachableTime	{ return T_AdvReachableTime; }
AdvRetransTimer		{ return T_AdvRetransTimer; }
AdvCurHopLimit		{ return T_AdvCurHopLimit; }
AdvDefaultLifetime	{ return T_AdvDefaultLifetime; }
AdvDefaultPreference	{ return T_AdvDefaultPreference; }
AdvSourceLLAddress	{ return T_AdvSourceLLAddress; }
RemoveAdvOnExit		{ return T_RemoveAdvOnExit; }

AdvOnLink		{ return T_AdvOnLink; }
AdvAutonomous		{ return T_AdvAutonomous; }
AdvValidLifetime	{ return T_AdvValidLifetime; }
AdvPreferredLifetime	{ return T_AdvPreferredLifetime; }
DeprecatePrefix		{ return T_DeprecatePrefix; }
DecrementLifetimes	{ return T_DecrementLifetimes; }

AdvRouterAddr		{ return T_AdvRouterAddr; }
AdvHomeAgentFlag	{ return T_AdvHomeAgentFlag; }
AdvIntervalOpt		{ return T_AdvIntervalOpt; }
AdvHomeAgentInfo	{ return T_AdvHomeAgentInfo; }
UnicastOnly		{ return T_UnicastOnly; }
UnrestrictedUnicast	{ return T_UnrestrictedUnicast; }
AdvRASolicitedUnicast	{ return T_AdvRASolicitedUnicast; }
AdvCaptivePortalAPI	{ return T_AdvCaptivePortalAPI; }

Base6Interface		{ return T_Base6Interface; }
Base6to4Interface	{ return T_Base6to4Interface; }

HomeAgentPreference	{ return T_HomeAgentPreference; }
HomeAgentLifetime	{ return T_HomeAgentLifetime; }

AdvRoutePreference	{ return T_AdvRoutePreference; }
AdvRouteLifetime	{ return T_AdvRouteLifetime; }
RemoveRoute		{ return T_RemoveRoute; }

AdvRDNSSPreference 	{ return T_AdvRDNSSPreference; }
AdvRDNSSOpen		{ return T_AdvRDNSSOpenFlag; }
AdvRDNSSLifetime	{ return T_AdvRDNSSLifetime; }
FlushRDNSS		{ return T_FlushRDNSS; }

AdvDNSSLLifetime	{ return T_AdvDNSSLLifetime; }
FlushDNSSL		{ return T_FlushDNSSL; }

MinDelayBetweenRAs      { return T_MinDelayBetweenRAs; }

AdvMobRtrSupportFlag	{ return T_AdvMobRtrSupportFlag; }

AdvContextLength	{ return T_AdvContextLength; }
AdvContextCompressionFlag { return T_AdvContextCompressionFlag; }
AdvContextID		{ return T_AdvContextID; }
AdvLifeTime		{ return T_AdvLifeTime; }
AdvContextPrefix	{ return T_AdvContextPrefix; }

AdvVersionLow		{ return T_AdvVersionLow; }
AdvVersionHigh		{ return T_AdvVersionHigh; }
Adv6LBRaddress		{ return T_Adv6LBRaddress; }

{addr}		{
			static struct in6_addr addr;
			if (inet_pton(AF_INET6, yytext, &addr) < 1) {
				return T_BAD_TOKEN;
			}

			yylval.addr = &addr;
			return IPV6ADDR;
		}

{naddr}		{
			static struct in6_addr addr;
			if (inet_pton(AF_INET6, &yytext[1], &addr) < 1) {
				return T_BAD_TOKEN;
			}

			yylval.addr = &addr;
			return NOT_IPV6ADDR;
		}

{number}	{
			unsigned long lnum;
			char *endp;
			lnum = strtoul(yytext, &endp, 10);
			if (*yytext == '\0' || *endp != '\0')
				return T_BAD_TOKEN;
			if (lnum > 0xFFFFFFFFUL)
				return T_BAD_TOKEN;	/* XXX */
			yylval.num = lnum;
			return NUMBER;
		}

{snum}		{ yylval.snum = atoi(yytext); return SIGNEDNUMBER; }

{decimal}	{ yylval.dec = atof(yytext); return DECIMAL; }

infinity	{ return INFINITY; }

on			{ yylval.num = 1; return SWITCH; }

off			{ yylval.num = 0; return SWITCH; }

low		{ yylval.snum = -1; return SIGNEDNUMBER; }

medium		{ yylval.snum = 0; return SIGNEDNUMBER; }

high		{ yylval.snum = 1; return SIGNEDNUMBER; }

{string}	{
			static char string[256];

			strncpy(string, yytext, sizeof(string));
			string[sizeof(string)-1] = '\0';
			yylval.str = string;
			return STRING;
		}

"{"|"}"|";"|"/"	{ return *yytext; }

.		{ return T_BAD_TOKEN; }
%%
