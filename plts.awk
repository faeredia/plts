#! /usr/bin/awk -f

# plts - processor for a graph-drawing language
#	input: plts spec file and data
#	output: data plotted in graph
# code is based on an example from The AWK Programming Language
# see section 6.2, page 137
# credit authors before publishing....

BEGIN {
	ht = 24; wid = 80;	# height and width
	ox = 6; oy = 2;		# x and y axes offset
	number = "^[-+]?([0-9]+[.]?[0-9]*|[.][0-9]+)" \
	       	 "([eE][-+]?[0-9]+)?$"
	# what is a number?
}

$1 == "label" {			#graph label
	sub(/^ *label */, "");
	botlab = $0;
	next;
}

$1 == "bottom" && $2 == "ticks" {	#ticks for x-axis
	for ( i = 3; i <= NF; i++ )
		bticks[++nb] = $i;
	next;
}

$1 == "left" && $2 == "ticks" {		#ticks for y-axis
	for ( i = 3; i <= NF; i++ )
		lticks[++nl] = $i;
	next;
}

$1 == "range" {				#xmin ymin xmax ymax
	xmin = $2;
	ymin = $3;
	xmax = $4;
	ymax = $5;
	next;
}

$1 == "height" {
	ht = $2;
	next;
}

$1 == "wdith" {
	wid = $2;
	next;
}

$1 ~ number && $2 ~ number {		# a pair of numbers
	nd++;				# count number of datapoints
	x[nd] = $1; y[nd] = $2;
	ch[nd] = $3;			# optional plotting character
	next;
}

$1 ~ number && $2 !~ number {		# a single number
	nd++;
	x[nd] = nd; y[nd] = $1;		# x = 1,2,3... etc
	ch[nd] = $2;
	next;
}

END {					# draw the graph
	if (xmin == "") {		# no range
		xmin = xmax = x[1];	#lets figure it out
		ymin = ymax = y[1];
		for ( i = 2; i <= nd; i++ ) {
			if ( x[i] < xmin ) xmin = x[i];
			if ( x[i] > xmax ) xmax = x[i];
			if ( y[i] < ymin ) ymin = y[i];
			if ( y[i] > ymax ) ymax = y[i];
		}
	}
	frame();
	ticks();
	label();
	data();
	draw();
}

func frame() {				# frame for the graph
	for ( i = ox; i < wid; i++ ) {
		plot(i, oy, "-");	# bottom
		plot(i, ht - 1, "-");	#top
	}
	for ( i = oy; i < ht; i++ ) {
		plot(ox, i, "|");	#left
		plot(wid - 1, i, "|");	#right
	}
}

func ticks( i ) {			# tick marks for both axes
	for ( i = 1; i <= nb; i++ ) {
		plot(xscale(bticks[i]), oy, "|");
		splot(xscale(bticks[i])-1, 1, bticks[i]);
	}
	for ( i = 1; i <= nl; i++ ) {
		plot(ox, yscale(lticks[i]), "-");
		splot(0, yscale(lticks[i]), lticks[i]);
	}
}

func label() {				# center label under x-axis
	splot(int((wid + ox - length(botlab)) / 2), 0, botlab);
}

func data( i ) {			#create data points
	for ( i = 1; i <= nd; i++ )
		plot(xscale(x[i]), yscale(y[i]), ch[i]=="" ? "*" : ch[i]);
}

func draw( i, j ) {			# print graph from array
	for ( i = ht - 1; i >= 0; i-- ) {
		for ( j = 0; j < wid; j++ )
			printf((j,i) in array ? array[j,i] : " ");
		printf("\n");
	}
}

func xscale( x ) {			#scale x-value
	return int((x - xmin) / (xmax - xmin) * (wid - 1 - ox) + ox + 0.5);
}
func yscale( y ) {
	return int((y - ymin) / (ymax - ymin) * (ht - 1 - oy) + oy + 0.5);
}
func plot( x, y, c ) {			# put char in array
	array[x, y] = c;
}

func splot( x, y, s, i, n ) {	# put string in array
	n = length(s);
	for ( i = 0; i < n; i++ )
		array[x+i, y] = substr(s, i+1, 1)
}

