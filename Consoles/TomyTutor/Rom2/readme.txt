Welcome to this part of the Tomy Tutor / Pyūta (ぴゅう太) Section.
The Tomy computer line was released through several models, in Japan and in the Usa.
There was a release announced for Europe, but no PAL units have ever been seen.

There was the:
- Tomy Tutor (USA), TP1000
- Tomy Pyūta (ぴゅう太) (JAPAN), TP1000
- Tomy Pyūta MkII (ぴゅう太) (JAPAN), TP1007
- Tomy Pyūta Jr. (ぴゅう太) (JAPAN), TP2001

The Rom2 chip content is an english BASIC version named Tomy Tutor BASIC.

The Rom2 chip is a 16 Kilobyte chip, that sits in the US Tomy Tutor, and only that US model came with an english BASIC, and therefore with a Rom2 chip.

The japanese models did not come with that chip or its content, but there were external upgrades to get this english BASIC implementation. One was a cartridge for the cartridge slot for the the Tomy Pyūta (ぴゅう太) MkII console.
Another was the Tomy Pyūta (ぴゅう太) BASIC1 interface for the extension port of a Tomy Pyūta (ぴゅう太) console.

To this date there is no known dump of those japanese cartridges. This would be helpful to verify its content (including its header) is identical to the Rom2 chip. Since it is always the english Tomy Tutor BASIC with the same manual, this is supposed until then. If you have such a cart please help here verify by providing a dump.

The Rom2 chip is wired up to be in the memory location >8000 - >BFFF of the 64Kbyte CPU memory.

This BASIC implementation always felt similar to the BASIC versions released for the TI-99, and developed by TI.
Even tokens were identified to be used similary, and many more similarities were found.
http://www.floodgap.com/retrobits/tomy/ti-vs-tomy.html

In late 2020 an attempt by Klaus Lukaschek was made to find the origin of the Rom2 assembly code within known source code for TI computers. This revealed that the Tomy Tutor BASIC is infact a minimally modified TI Extended BASIC. The TI community has the preserved source code files of TI Extended BASIC with their full comments by the actual TI software developers.
See this section in github for its Rom Sourcecode Files:
https://github.com/kl9900/TMS9900Family/tree/master/Consoles/TI-99/ExtendedBasic/Rom

The mentioned set of files was changed to assemble towards their identified memory locations from the Tomy computer. Single code lines or passages, that were not found in the Rom2, were also removed from the adapted source code files to generate the same binary Rom2 content.

The attempt of being able to generate the binary of Rom2 solely from the TI Extended Basic Source code files was mostly succeeded.
At the beginning and and at the end of the chip is still data or code not yet mapped. Moving the project towards this repository hopefully completes the attempt.

Rom2 content:
>8000 - >9028 unknown (might be GPL)
>9029 - >B90F identical output (all coming from assembly source code files from TI Extended BASIC)
>B910 - >BFFF unknown

10.5 Kilobyte of continued memory is fully known.
The remaining 1.5 Kilobyte of Extended Basic are not found in the Rom2 binary.

The original TI Extended Basic is using two Rom banks, each with 8 Kilobyte. The banks have the first 4 Kilobyte identical, ending up with 12 Kilobyte of actual assembly Rom code. But in addition to work Extended Basic is using 4 Grom Banks a 6 Kilobyte each, making 24 Kilobyte of GPL code, GPL is a TI invented programming language. The Tomy is known to use GPL, but not by getting the data from Grom chips. So the required GPL code has to be, at least mostly, in Rom1.

Changes from the original TI Extended Basic Source code files were done with least possible changes.
Each changed line was documented with a "*TOMY*" comment field at the end of the line, starting at position 75 to stay within the 80 character line limit.

It is recommend to use a diff tool to compare the referred set of TI Extended Basic Source code files with this set.
For Windows I can recommend WinMerge.

Sometimes whole files got excluded because they were not found to be included in the Rom2 binary. Excluded files covered the ERAM (External RAM) and/or GROM handling. In addition subprogs.asm and subprogs2.asm were not found to be in the Rom2 binary. Any excludes might be identified to be a mistake but time will tell.
Most times the only changes that differ Tomy BASIC from TI Extended Basic were some lines or whole sections to not include. Then there are commented sections in the TI Extended Basic code (to document old revisions) that got uncommented (to be included) in the Tomy BASIC.

Having a continued binary match across 10 Kilobyte proves that Tomy Tutor BASIC copied the code from TI Extended Basic. Doing this without a license means a big copyright violation. If you have any info about license talks or even an agreement in the 80s, please get in touch with the community.
https://atariage.com/forums/forum/345-tomy-tutor-cc40-992-998-cortex-990-mini/

Working from the original TI Sourcecode files brings the following BIG advantages:
- no need to disassemble binary content any more, with lots of guessing and question marks.
- the basic implementation is now well documented with their original variables, labels, comments, structure, sorting and all developer notes.
- able to understand and document the limits
- reveal undocumented features
- nail down bugs of this implementation
- able to fix discovered bugs and release updated versions with ease.
- adding assembly language execution from BASIC, similar to how TI Extended Basic does it.
- allow integration of drivers for hardware projects
- having this ressource is tremendous useful for emulator developers to analyze and overcome nasty emulation bugs
