/*
    Copyright (c) 2013, Taiga Nomi
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
    * Neither the name of the <organization> nor the
    names of its contributors may be used to endorse or promote products
    derived from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
    EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
    DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
    DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
    ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
#pragma once
#include "util.h"
#include "partial_connected_layer.h"
#include "image.h"
#include <assert.h>
#include <c++/4.8.3/algorithm>



namespace tiny_cnn {


template<typename N, typename Activation>
class convolutional_layer_hw : public layer<N, Activation> {
public:

    convolutional_layer_hw(int in_width, int in_height, int window_size, int in_channels, int out_channels)
    : layer<N, Activation>(in_width * in_height * in_channels, ((in_width - window_size + 1)/2) * ((in_width - window_size + 1)/2) * out_channels,
    window_size * window_size * in_channels * out_channels, out_channels)
    {
    	avg_pool_coffs.resize(out_channels);
    	avg_pool_bias.resize(out_channels);
    }

    convolutional_layer_hw(int in_width, int in_height, int window_size, int in_channels, int out_channels, const connection_table& connection_table)
        : layer<N, Activation>(in_width * in_height * in_channels, ((in_width - window_size + 1)/2) * ((in_width - window_size + 1)/2) * out_channels,
		window_size * window_size * in_channels * out_channels, out_channels)

    {
        this->remap();
    }

    virtual const vec_t& forward_propagation(const vec_t& in, int index) {

    	for (int i = 0; i < 6; i++) {
			vec_t weights;
			weights.insert(weights.end(), this->W_.begin()+i*25, this->W_.begin()+25*(i+1));
			ConvLayerValues clv = {
					in.begin(),
					weights.begin(),
					32,
					5,
					this->b_[i],
					avg_pool_coffs[i],
					avg_pool_bias[i],
					0.25
			};
			std::vector<ConvLayerValues> clv_vec = {clv};
			CalculateClUsingHWAccelerator(clv_vec, this->output_[index].begin()+i*14*14);
		}

//		for (int i = 0; i < this->out_size_; i++) {
//			const wi_connections& connections = this->out2wi_[i];
//			float_t a = 0.0;
//
//			for (auto connection : connections)// 13.1%
//				a += this->W_[connection.first] * in[connection.second]; // 3.2%
//
//			a *= this->scale_factor_;
//			a += this->b_[this->out2bias_[i]];
//			float out_val = this->a_.f(a);
//
//			float e = all_fm[i];
//			if(!CompareFloats(e, out_val)) {
//				printf("Expected: %f. Actual: %f.\n\r", out_val, e);
//			}
//			this->output_[index][i] = out_val; // 9.6%
//		}


		return this->next_ ? this->next_->forward_propagation(this->output_[index], index) : this->output_[index]; // 15.6%
	}

    int param_size() const {
	}

	int connection_size() const {

	}

	int fan_in_size() const {

	}

	void connect_weight(int input_index, int output_index, int weight_index) {

	}

	void connect_bias(int bias_index, int output_index) {
	}

	virtual const vec_t& back_propagation(const vec_t& current_delta, int index) {
		vec_t lol;
		return lol;
	}

	const vec_t& back_propagation_2nd(const vec_t& current_delta2) {
		vec_t lol;
		return lol;
	}

	// remove unused weight to improve cache hits
	void remap() {
	}

	virtual void load(std::istream& is) {
		for (auto& w : this->W_){
			float f;
			is.read((char*)&f, sizeof(f));
			w = f;
		}
		for (auto& b : this->b_) {
			float f;
			is.read((char*)&f, sizeof(f));
			b = f;
		}
		for (auto& c : avg_pool_coffs) {
			float f;
			is.read((char*)&f, sizeof(f));
			c = f;
		}

		for (auto& avg_b : avg_pool_bias) {
			float f;
			is.read((char*)&f, sizeof(f));
			avg_b = f;
		}
	}




private:
	vec_t avg_pool_coffs;
	vec_t avg_pool_bias;
};


template <typename Char, typename CharTraits, typename N, typename Activation>
std::basic_istream<Char, CharTraits>& operator >> (std::basic_istream<Char, CharTraits>& os, convolutional_layer_hw<N, Activation>& v) {
	v.load(os);
    return os;
}

} // namespace tiny_cnn
