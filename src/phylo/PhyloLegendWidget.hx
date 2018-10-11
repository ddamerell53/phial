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

class PhyloLegendWidget {
    var canvas : PhyloCanvasRenderer;
    var container : Dynamic;
    var legendContainer : Dynamic;

    public function new(canvas : PhyloCanvasRenderer) {
        this.canvas = canvas;

        build();
    }

    public function build(){
        addContainer();
    }

    public function getCanvas() : PhyloCanvasRenderer{
        return canvas;
    }

    public function getContainer() : Dynamic {
        return container;
    }

    public function addContainer(){
        container = js.Browser.document.createElement('div');

        container.style.display = 'inline-block';
        container.style.minWidth = '160px';
        container.style.position = 'relative';
        container.style.verticalAlign = 'top';
        container.style.height = '100%';
        container.style.backgroundColor = '#f7f8fb';

        container.marginLeft = '0px';
        container.marginTop = '0px';

        container.innerHTML = '<h1 style="margin-left:5px;margin-right:5px">Legend</h1>';

        legendContainer = js.Browser.document.createElement('div');

        container.appendChild(legendContainer);

        redraw();
    }

    public function clearLegendContainer(){
        while(legendContainer.firstChild){
            legendContainer.removeChild(legendContainer.firstChild);
        }
    }

    public function getLegendContainer(){
        return legendContainer;
    }

    public function redraw(){
        clearLegendContainer();

        var annotationManager = canvas.getAnnotationManager();

        var activeAnnotations = annotationManager.getActiveAnnotations();

        for(annotationDef in activeAnnotations){
            var config = canvas.getAnnotationManager().getAnnotationConfigByName(annotationDef.label);

            if(config.legendFunction != null){
                var func = config.legendFunction;

                func(this, config);
            }
        }
    }
}
