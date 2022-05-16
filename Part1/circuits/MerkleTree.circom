pragma circom 2.0.0;
include "../node_modules/circomlib/circuits/mux1.circom";

include "../node_modules/circomlib/circuits/poseidon.circom";
include "./PoseidonHasher.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
     
    var numberOfLeafHashers = 2**n / 2;

    // The number of HashLeftRight components which will be used to hash the
    // output of the leaf hasher components
    var numIntermediateHashers = numberOfLeafHashers - 1;


    //for The total number of hashers
    var numHashers = (2**n) - 1;
    component hashers[numHashers];

    // Instantiatating all  the hashers
    
    for (var i=0; i < numHashers; i++) {
        hashers[i] = HashLeftRight();
    }

    // putting on leaf values into the leaf hashers
    for (var i=0; i < numberOfLeafHashers; i++){
        hashers[i].left <== leaves[i*2];
        hashers[i].right <== leaves[i*2+1];
    }

    // putting on the outputs of the leaf hashers to the intermediate hasher inputs
    var k = 0;
    for (var i=numberOfLeafHashers; i<numberOfLeafHashers + numIntermediateHashers; i++) {
        hashers[i].left <== hashers[k*2].hash;
        hashers[i].right <== hashers[k*2+1].hash;
        k++;
    }

    // putting on the output of the final hash to the root
    root <== hashers[numHashers-1].hash;
}



template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component poseidonHash[n];
    component muxi[n];

    signal hashes[n + 1];
    hashes[0] <== leaf;

    for (var i = 0; i < n; i++) {
        path_index[i] * (1 - path_index[i]) === 0;

        poseidonHash[i] = Poseidon(2);
        muxi[i] = MultiMux1(2);

        muxi[i].c[0][0] <== hashes[i];
        muxi[i].c[0][1] <== path_elements[i];

        muxi[i].c[1][0] <== path_elements[i];
        muxi[i].c[1][1] <== hashes[i];

        muxi[i].s <== path_index[i];

        poseidonHash[i].inputs[0] <== muxi[i].out[0];
        poseidonHash[i].inputs[1] <== muxi[i].out[1];

        hashes[i + 1] <== poseidonHash[i].out;
    }

    root <== hashes[n];
}



































