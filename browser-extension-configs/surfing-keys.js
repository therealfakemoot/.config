/* global api, settings, window, document */

// Compatibility Prefix
const { imap, imapkey, map, mapkey, removeSearchAlias, unmap, unmapAllExcept, vmapkey, vunmap } = api;

//──────────────────────────────────────────────────────────────────────────────

// ---- SETTINGS ----
// https://github.com/brookhong/Surfingkeys#edit-your-own-settings
settings.focusAfterClosed = "last";
settings.scrollStepSize = 300;
settings.tabsThreshold = 7;
settings.modeAfterYank = "Normal";
settings.hintAlign = "left";
settings.theme = `
	#sk_status, #sk_find {
		font-size: 16pt;
	}
}`;

//──────────────────────────────────────────────────────────────────────────────

// IGNORE LIST
settings.blocklistPattern = undefined; /* eslint-disable-line no-undefined */

// unmap jk on google for web search navigator (vimium-like controls for google only)
unmap("j", /google/);
unmap("k", /google/);

//──────────────────────────────────────────────────────────────────────────────

// ---- Mappings -----
map("J", "P"); // page down
map("K", "U"); // page up

map("e", "R"); // one tab right
map("b", "E"); // one tab right
map("i", "x"); // close tab
map("u", "X"); // reopen tab
map("wq", "gx0"); // close tabs on left
map("we", "gx$"); // close tabs on right
map("ww", "gx$"); // close all other tabs
map("<", "<<"); // move tab to the left
map(">", ">>"); // move tab to the right

map("F", "C"); // Open Hint in new tab

map("B", "ab"); // bookmark
map("X", ";dh"); // delete bookmark
map("m", "<Alt-m>"); // mute tab
map("M", ";pm"); // markdown preview

map("ye", "yv"); // yank text of an element

map("wv", "W"); // move tab to new window (vsplit with Hammerspoon)
map("wm", ";gw"); // merge all windows to current one

map("gi", "I"); // enter insert field
map("a", "p"); // disable for one key

map("h", "S"); // History Back/Forward
map("l", "D");

map("H", "[["); // Next/Prev Page
map("L", "]]");

map("I", ";j"); // inspector

map("-", "/"); // find
map("+", "*"); // find selection

map("ge", ";U"); // Edit current URL
map(",", ";e"); // Settings
map("t", "T"); // choose tab via hint

map("p", "cc"); // open URL from clipboard or selection

// toggle fullscreen, mainly because of YouTube
mapkey("Z", "Fullscreen", function () {
	if (window.fullScreen) {
		document.exitFullscreen();
	} else {
		document.documentElement.requestFullscreen();
	}
});

//──────────────────────────────────────────────────────────────────────────────

// unmapping unused stuff
removeSearchAlias("b", "s");
removeSearchAlias("d", "s");
removeSearchAlias("g", "s");
removeSearchAlias("h", "s");
removeSearchAlias("w", "s");
removeSearchAlias("y", "s");
removeSearchAlias("s", "s");
removeSearchAlias("e", "s");

unmap(";ql");
unmap("]]");
unmap("[[");
unmap("S");
unmap("W");
unmap("R");
unmap("C");
unmap("W");
unmap("yG");
unmap("yS");
unmap(";w");
unmap("P");
unmap("D");
unmap("yj");
unmap("ys");
unmap("yv");
unmap("yma");
unmap("U");
unmap("cs");
unmap("cS");
unmap("$");
unmap("0");
unmap("<Alt-i>");
unmap("I");
unmap("q");
unmap(";m");
unmap(";fs");
unmap(";di");
unmap("gf");
unmap("cf");
unmap("yT");
unmap("gxp");
unmap(";U");
unmap(";u");
unmap("<Ctrl-6>");
unmap("gx0");
unmap("gx$");
unmap("<Alt-p>");
unmap("<Alt-m>");
unmap("gxt");
unmap("gxT");
unmap("gT");
unmap("gt");
unmap("g?");
unmap("g#");
unmap("on");
unmap("on");
unmap("zr");
unmap("zi");
unmap("zo");
unmap(";gt");
unmap(";e");
unmap(";v");
unmap("yq");
unmap("yQ");
unmap("yh");
unmap(";yQ");
unmap("d");
unmap("cp");
unmap(";pa");
unmap(";pf");
unmap(";pj");
unmap(";pp");
unmap("cc");
unmap(";yh");
unmap(";dh");
unmap("gs");
unmap("gn");
unmap("gb");
unmap("gd");
unmap("<Ctrl-'>");
unmap("zv");
unmap(";pb");
unmap(";gw");
unmap("gxx");
unmap("zt");
unmap(";pm");
unmap("zb");
unmap(";pc");
unmap(";ps");
unmap(";pd");
unmap(";ap");
unmap(";j");
unmap("<Ctrl-Alt-i>");
unmap("<Ctrl-h>");
unmap("<Ctrl-j>");
unmap("g0");
unmap("g$");
unmap("ga");
unmap("gc");
