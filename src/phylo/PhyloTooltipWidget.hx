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

class PhyloTooltipWidget extends PhyloInfoWidget {

    public function new(parent : Dynamic, message : String, title : String) {
        super(parent, message, title);
    }


    override public function addContent(){
        super.addContent();

        addConfirmationCheckbox();
    }

    public function addConfirmationCheckbox(){
        var input :Dynamic = js.Browser.document.createElement('input');
        input.setAttribute('type', 'checkbox');

        content.appendChild(input);

        input.addEventListener('change', function(event) {
            if(input.checked) {
                var cookies = untyped __js__('Cookies');
                cookies.set('annot-icons-tip', true);

            }
            else {
                //not checked
            }
        });

    }
}