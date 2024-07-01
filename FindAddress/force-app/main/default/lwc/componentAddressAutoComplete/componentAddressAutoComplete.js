import { LightningElement } from 'lwc';
import getTravelDetails from '@salesforce/apex/TravelController.getTravelDetails';

export default class ComponentAddressAutoComplete extends LightningElement {

    origin;
    destination;
    @track result;

    renderedCallback() {
        if (!this.googleMapsInitialized) {
            this.loadGoogleMaps();
        }
    }

    loadGoogleMaps() {
        Promise.all([
            this.loadScript('https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&libraries=places')
        ]).then(() => {
            this.googleMapsInitialized = true;
            this.initializeAutocomplete();
        }).catch(error => {
            console.error('Google Maps API load error: ', error);
        });
    }

    loadScript(url) {
        return new Promise((resolve, reject) => {
            const script = document.createElement('script');
            script.src = url;
            script.onload = resolve;
            script.onerror = reject;
            document.head.appendChild(script);
        });
    }

    initializeAutocomplete() {
        const originInput = this.template.querySelector('[data-id="origin"]');
        const destinationInput = this.template.querySelector('[data-id="destination"]');

        this.originAutocomplete = new google.maps.places.Autocomplete(originInput);
        this.destinationAutocomplete = new google.maps.places.Autocomplete(destinationInput);

        google.maps.event.addListener(this.originAutocomplete, 'place_changed', () => {
            this.origin = this.originAutocomplete.getPlace().formatted_address;
        });

        google.maps.event.addListener(this.destinationAutocomplete, 'place_changed', () => {
            this.destination = this.destinationAutocomplete.getPlace().formatted_address;
        });
    }

    getDirections() {
        getTravelDetails({ origin: this.origin, destination: this.destination })
            .then(result => {
                this.result = result;
            })
            .catch(error => {
                console.error('Error getting travel details: ', error);
            });
    }

    handleInputChange(event) {
        const field = event.target.dataset.id;
        if (field === 'origin') {
            this.origin = event.target.value;
        } else if (field === 'destination') {
            this.destination = event.target.value;
        }
    }
}