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

class PhyloHighlightWidget extends PhyloGlassPaneWidget {
    public var highlightInputs : Array<Dynamic>;
    public var canvas : PhyloCanvasRenderer;

    public function new(parent : Dynamic, canvas : PhyloCanvasRenderer) {
        this.canvas = canvas;

        super(parent,'Select genes to highlight in tree', true);
    }

    override public function onClose(){
        canvas.getConfig().highlightedGenes=new Map<String, Bool>();

        for(inputElement in highlightInputs){
            if(inputElement.checked){
                canvas.getConfig().highlightedGenes.set(inputElement.getAttribute('value'), true);
            }
        }

        canvas.redraw();
    }

    override public function addContent(){
        super.addContent();

        addHighlightList();
    }

    public function addHighlightList(){
        var formContainer = js.Browser.document.createElement('div');
        formContainer.style.margin = 'auto';

        highlightInputs = new Array<Dynamic>();

        var targets = canvas.getRootNode().targets;

        targets.sort(function(a, b) {
            var targetA = a.toUpperCase();
            var targetB = b.toUpperCase();
            return (targetA < targetB) ? -1 : (targetA > targetB) ? 1 : 0;
        });

        var i = 0;
        for(target in targets){
            if(target == null || target == ''){
                continue;
            }

            i += 1;

            var name = 'target_highlight_' + i;

            var inputLabel = js.Browser.document.createElement('label');
            inputLabel.setAttribute('for', name);
            inputLabel.innerText = target;
            inputLabel.style.width = '60px';
            inputLabel.style.marginBottom = '5px';
            inputLabel.style.display = 'inline-block';

            var inputElement = js.Browser.document.createElement('input');
            inputElement.setAttribute('type', 'checkbox');
            inputElement.setAttribute('value', target);
            inputElement.setAttribute('name', name);
            inputElement.style.width = '15px';
            inputElement.style.height = '15px';
            inputElement.style.display = 'inline-block';
            inputElement.style.marginRight = '15px';

            highlightInputs.push(inputElement);

            formContainer.appendChild(inputLabel);
            formContainer.appendChild(inputElement);

            if(i % 7 == 0){
                formContainer.appendChild(js.Browser.document.createElement('br'));
            }
        }

        content.appendChild(formContainer);
    }
}
