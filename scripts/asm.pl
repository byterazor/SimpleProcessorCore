#!/usr/bin/perl
#
# Small assembler for the Simple Processor Core
#

my $nr_instr_bytes = 4;
my $nr_opcode_bits = 6;
my $nr_reg_bits    = 5;
my $startaddr      = -1;

# mnemonnic to opcode conversion
my %opcodes = (
	'shl'  => 0x00,
	'shr'  => 0x01,
	'sto'  => 0x02,
	'loa'  => 0x03,
	'add'  => 0x04,
	'sub'  => 0x05,
	'addc' => 0x06,
	'subc' => 0x07,
	'or'   => 0x08,
	'and'  => 0x09,
	'xor'  => 0x0A,
	'not'  => 0x0B,
	'jpz'  => 0x0C,
	'jpc'  => 0x0D,
	'jmp'  => 0x0E,
	'lui'  => 0x0F,
	'jmc'  => 0x10,
	'ret'  => 0x11,
	'hlt'  => 0x3F
);

#---------------------------------------------------------------------------
#  main program
#---------------------------------------------------------------------------

my $filename = $ARGV[0];

my %labels;

# check if file exists
if ( !-e $filename ) {
	die("file does not exist\n");
}

open my $src, "<" . $filename;

my $addr  = $startaddr;
my $lines = 0;

my @instructions;
my $valid;

while ( my $line = <$src> ) {

	$line =~ /^(\S+)\s(.*)$/;
	my $INSTR = $1;
	my $REST  = $2;

	$addr++;
	$lines++;
	my $opc   = $opcodes{"$INSTR"};
	my $label = "";
	$opc   = $opc << 26;
	$valid = 1;

	if ( $INSTR eq "shl" ) {
		if ( $REST =~ /^[\s\$]+(.*),[\s\$]+(.*),[\s\$]+(.*)$/ ) {
			my $dst = $1;
			my $op1 = $2;
			my $op2 = $3;
			$dst =~ s/\s//g;
			$dst = $dst << 21;
			$opc = $opc | $dst;

			$op1 =~ s/\s//g;
			$op1 = $op1 << 16;
			$opc = $opc | $op1;

			$op2 =~ s/\s//g;
			$op2 = $op2 << 11;
			$opc = $opc | $op2;
		}
		else {
			die("ASM: wrong number of parameters for shl in line $lines\n");
		}
	}
	elsif ( $INSTR eq "shr" ) {
		if ( $REST =~ /^[\s\$]+(.*),[\s\$]+(.*),[\s\$]+(.*)$/ ) {
			my $dst = $1;
			my $op1 = $2;
			my $op2 = $3;
			$dst =~ s/\s//g;
			$dst = $dst << 21;
			$opc = $opc | $dst;

			$op1 =~ s/\s//g;
			$op1 = $op1 << 16;
			$opc = $opc | $op1;

			$op2 =~ s/\s//g;
			$op2 = $op2 << 11;
			$opc = $opc | $op2;
		}
		else {
			die("ASM: wrong number of parameters for shr in line $lines\n");
		}
	}
	elsif ( $INSTR eq "sto" ) {
		if ( $REST =~ /^\$(.*),(.*)$/ ) {
            my $dst = $1;
            $dst =~ s/\s//g;
            $dst = $dst << 16;
            $opc = $opc | $dst;

            my $imm = $2;
            $imm =~ s/\s//g;

            $opc = $opc | $imm;
        }
        else {
            die("ASM: wrong number of parameters for sto in line $lines\n")
              ;
        }
	}
	elsif ( $INSTR eq "loa" ) {
		if ( $REST =~ /^\$(.*),(.*)$/ ) {
            my $dst = $1;
            $dst =~ s/\s//g;
            $dst = $dst << 21;
            $opc = $opc | $dst;

            my $imm = $2;
            $imm =~ s/\s//g;

            $opc = $opc | $imm;
        }
        else {
            die("ASM: wrong number of parameters for sto in line $lines\n")
              ;
        }
	}
	elsif ( $INSTR eq "add" ) {
		if ( $REST =~ /^[\s\$]+(.*),[\s\$]+(.*),[\s\$]+(.*)$/ ) {
			my $dst = $1;
			my $op1 = $2;
			my $op2 = $3;
			$dst =~ s/\s//g;
			$dst = $dst << 21;
			$opc = $opc | $dst;

			$op1 =~ s/\s//g;
			$op1 = $op1 << 16;
			$opc = $opc | $op1;

			$op2 =~ s/\s//g;
			$op2 = $op2 << 11;
			$opc = $opc | $op2;
		}
		else {
			die("ASM: wrong number of parameters for add in line $lines\n");
		}
	}
	elsif ( $INSTR eq "sub" ) {
		if ( $REST =~ /^[\s\$]+(.*),[\s\$]+(.*),[\s\$]+(.*)$/ ) {
			my $dst = $1;
			my $op1 = $2;
			my $op2 = $3;
			$dst =~ s/\s//g;
			$dst = $dst << 21;
			$opc = $opc | $dst;

			$op1 =~ s/\s//g;
			$op1 = $op1 << 16;
			$opc = $opc | $op1;

			$op2 =~ s/\s//g;
			$op2 = $op2 << 11;
			$opc = $opc | $op2;
		}
		else {
			die("ASM: wrong number of parameters for sub in line $lines\n");
		}
	}
	elsif ( $INSTR eq "addc" ) {
		if ( $REST =~ /^[\s\$]+(.*),[\s\$]+(.*),[\s\$]+(.*)$/ ) {
			my $dst = $1;
			my $op1 = $2;
			my $op2 = $3;
			$dst =~ s/\s//g;
			$dst = $dst << 21;
			$opc = $opc | $dst;

			$op1 =~ s/\s//g;
			$op1 = $op1 << 16;
			$opc = $opc | $op1;

			$op2 =~ s/\s//g;
			$op2 = $op2 << 11;
			$opc = $opc | $op2;
		}
		else {
			die("ASM: wrong number of parameters for addc in line $lines\n");
		}
	}
	elsif ( $INSTR eq "subc" ) {
		if ( $REST =~ /^[\s\$]+(.*),[\s\$]+(.*),[\s\$]+(.*)$/ ) {
			my $dst = $1;
			my $op1 = $2;
			my $op2 = $3;
			$dst =~ s/\s//g;
			$dst = $dst << 21;
			$opc = $opc | $dst;

			$op1 =~ s/\s//g;
			$op1 = $op1 << 16;
			$opc = $opc | $op1;

			$op2 =~ s/\s//g;
			$op2 = $op2 << 11;
			$opc = $opc | $op2;
		}
		else {
			die("ASM: wrong number of parameters for subc in line $lines\n");
		}
	}
	elsif ( $INSTR eq "or" ) {
		if ( $REST =~ /^[\s\$]+(.*),[\s\$]+(.*),[\s\$]+(.*)$/ ) {
			my $dst = $1;
			my $op1 = $2;
			my $op2 = $3;
			$dst =~ s/\s//g;
			$dst = $dst << 21;
			$opc = $opc | $dst;

			$op1 =~ s/\s//g;
			$op1 = $op1 << 16;
			$opc = $opc | $op1;

			$op2 =~ s/\s//g;
			$op2 = $op2 << 11;
			$opc = $opc | $op2;
		}
		else {
			die("ASM: wrong number of parameters for or in line $lines\n");
		}
	}
	elsif ( $INSTR eq "and" ) {
		if ( $REST =~ /^[\s\$]+(.*),[\s\$]+(.*),[\s\$]+(.*)$/ ) {
			my $dst = $1;
			my $op1 = $2;
			my $op2 = $3;
			$dst =~ s/\s//g;
			$dst = $dst << 21;
			$opc = $opc | $dst;

			$op1 =~ s/\s//g;
			$op1 = $op1 << 16;
			$opc = $opc | $op1;

			$op2 =~ s/\s//g;
			$op2 = $op2 << 11;
			$opc = $opc | $op2;
		}
		else {
			die("ASM: wrong number of parameters for and in line $lines\n");
		}
	}
	elsif ( $INSTR eq "xor" ) {
		if ( $REST =~ /^[\s\$]+(.*),[\s\$]+(.*),[\s\$]+(.*)$/ ) {
			my $dst = $1;
			my $op1 = $2;
			my $op2 = $3;
			$dst =~ s/\s//g;
			$dst = $dst << 21;
			$opc = $opc | $dst;

			$op1 =~ s/\s//g;
			$op1 = $op1 << 16;
			$opc = $opc | $op1;

			$op2 =~ s/\s//g;
			$op2 = $op2 << 11;
			$opc = $opc | $op2;
		}
		else {
			die("ASM: wrong number of parameters for xor in line $lines\n");
		}
	}
	elsif ( $INSTR eq "not" ) {
		if ( $REST =~ /^[\s\$]+(.*)$/ ) {
			my $dst = $1;
			$dst =~ s/\s//g;
			$dst = $dst << 21;
			$opc = $opc | $dst;

		}
		else {
			die("ASM: wrong number of parameters for add in line $lines\n");
		}
	}
	elsif ( $INSTR eq "jpz" ) {
		$label = $REST;
	}
	elsif ( $INSTR eq "jpc" ) {
		$label = $REST;
	}
	elsif ( $INSTR eq "jmc" ) {
		$label = $REST;
		
        my $dst = 31;
        $dst = $dst << 21;
        $opc = $opc | $dst;
            
    }
	elsif ( $INSTR eq "jmp" ) {
		$label = $REST;
	}
	elsif ( $INSTR eq "hlt" ) {
	}
	elsif ( $INSTR eq "lui" ) {
		if ( $REST =~ /^\$(.*),(.*)$/ ) {
			my $dst = $1;
			$dst =~ s/\s//g;
			$dst = $dst << 21;
			$opc = $opc | $dst;

			my $imm = $2;
			$imm =~ s/\s//g;

			$opc = $opc | $imm;
		}
		else {
			die("ASM: wrong number of parameters for lui in line $lines\n")
			  ;
		}
	}
	elsif ( $INSTR eq "ret" ) {
		my $op1=31;
        $op1 = $op1 << 16;
        $opc = $opc | $op1;
        
    }
	elsif ( $INSTR =~ /^(.*):$/ ) {
		$labels{$1} = $addr;
		$addr--;
		$valid = 0;
	}
	else {
		$addr--;
		$valid = 0;
	}

	if ( $valid == 1 ) {
		$line =~ s/\n//;

		my $instruction = {};

		$instruction->{addr}    = $addr;
		$instruction->{opc}     = $opc;
		$instruction->{comment} = $line;
		$instruction->{label}   = $label;
        
        if ($line =~/jmc/) {
        	print "-" .$instruction->{label}."-\n";
        }        
		push( @instructions, $instruction );

	}
}
close $src;

# correct labels
for my $i (@instructions) {
	if ( $i->{label} =~ /\S+/ ) {
		for my $l ( keys %labels ) {

			if ( $i->{label} eq $l ) {
				$i->{opc} = $i->{opc} | $labels{$l};
			}
		}
	}
}


for my $i (@instructions) {
	if ($ARGV[1] eq "-vhdl") {
	   printf("%4s \t => B\"%.32b\", --%s\n ",$i->{addr}, $i->{opc}, $i->{comment});	
	} 
    elsif($ARGV[1] eq "-raw") {
        printf("%.32b\n",$i->{opc});
    }else {
	   printf( "%4s %.32b #%s\n", $i->{addr}, $i->{opc}, $i->{comment} );
	}
}

