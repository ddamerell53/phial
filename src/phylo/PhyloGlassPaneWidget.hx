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

class PhyloGlassPaneWidget extends PhyloWindowWidget{

    public function new(parent : Dynamic, title : String, modal : Bool = true) {
        super(parent, title, modal);

        container.style.width = '100%';
        container.style.height = '100%';
        container.style.backgroundColor = 'rgba(0,0,0,0.4)';

        header.style.width = '50%';
        header.style.margin = 'auto';
        header.style.position = 'initial';
        header.style.padding = '20px';

        content.style.backgroundColor = '#fefefe';
        content.style.margin = 'auto';
        content.style.padding = '20px';
        content.style.width = '50%';
    }

    override public function addContainer(){
        super.addContainer();
    }
}
