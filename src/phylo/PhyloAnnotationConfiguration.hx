package phylo;

/*
* PHIAL (Phylogenetic interactve annotation library)
* Written in 2018 by
*   David Damerell <david.damerell@sgc.ox.ac.uk>, Leonidas Koukouflis <leonidas.koukouflis@sgc.ox.ac.uk>,
*   Lihua Liu <liulihua1@gmail.com> Sefa Garsot <>
*   Brian Marsden <brian.marsden@sgc.ox.ac.uk> Matthieu Schapira <matthieu.schapira@utoronto.ca>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

class PhyloAnnotationConfiguration {
    public var name : String;
    public var annotationFunction : Dynamic;
    public var styleFunction : Dynamic;
    public var legendFunction : Dynamic;
    public var infoFunction : Dynamic;
    public var shape : Dynamic;
    public var colour : Dynamic;
    public var _skipped : Bool;

    public function new() {

    }

    public function getColourOldFormat() : Dynamic{
        return {color: colour, 'used':'false'};
    }

    public function isSkip() : Bool {
        return _skipped;
    }
}
