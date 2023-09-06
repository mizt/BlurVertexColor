#import <Foundation/Foundation.h>
#import <simd/simd.h>
#import <vector>

int main(int argc, char *argv[]) {
	@autoreleasepool {
		
		NSString *src = [NSString stringWithContentsOfFile:@"./marge.obj" encoding:NSUTF8StringEncoding error:nil];
		NSArray *lines = [src componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
		
		NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
		
		std::vector<float> v;
		std::vector<unsigned int> f;
		
		for(int k=0; k<[lines count]; k++) {
			NSArray *arr = [lines[k] componentsSeparatedByCharactersInSet:whitespaces];
			if([arr count]>0) {
				if([arr[0] isEqualToString:@"v"]) {
					v.push_back([arr[1] doubleValue]);
					v.push_back([arr[2] doubleValue]);
					v.push_back([arr[3] doubleValue]);
					v.push_back([arr[4] doubleValue]);
					v.push_back([arr[5] doubleValue]);
					v.push_back([arr[6] doubleValue]);
				}
				else if([arr[0] isEqualToString:@"f"]) {
					f.push_back([arr[1] intValue]-1);
					f.push_back([arr[2] intValue]-1);
					f.push_back([arr[3] intValue]-1);
				}
			}
		}
		
		unsigned int length = v.size()/6;

		unsigned int *use = new unsigned int[length];
		for(int n=0; n<length; n++) use[n] = false;
		std::vector<std::vector<int>> indices;
		
		for(int n=0; n<length; n++) {
			
			float x = v[n*6+0];
			float y = v[n*6+1];
			float z = v[n*6+2];
			
			if(!use[n]) {
				
				use[n] = true;
				indices.push_back({});
				indices[indices.size()-1].push_back(n);
				
				for(int k=n+1; k<length; k++) {
					
					if(x==v[k*6+0]&&y==v[k*6+1]&&z==v[k*6+2]) {
						use[k] = true;
						indices[indices.size()-1].push_back(k);
					}
				}
			}
		}
		
		std::vector<std::vector<int>> group;
		for(int n=0; n<indices.size(); n++) {
			
			group.push_back({});
			
			std::vector<int> *tmp = &indices[n];
			int len = tmp->size();
			
			for(int k=0; k<len; k++) {
				group[n].push_back((*tmp)[k]);
			}
			
			for(int l=0; l<f.size()/3; l++) {
				
				unsigned int face[3] = {
					f[l*3+0],
					f[l*3+1],
					f[l*3+2]
				};
				
				for(int k=0; k<len; k++) {
					
					int target = -1;
					
					if(face[0]==(*tmp)[k]) target = 0;
					if(face[1]==(*tmp)[k]) target = 1;
					if(face[2]==(*tmp)[k]) target = 2;
					
					if(target!=-1) {
						if(target!=0) group[n].push_back(face[0]);
						if(target!=1) group[n].push_back(face[1]);
						if(target!=2) group[n].push_back(face[2]);
					}
				}
			}
		}
	
		for(int n=0; n<group.size(); n++) {
			
			float r = 0;
			float g = 0;
			float b = 0;
			
			for(int k=0; k<group[n].size(); k++) {
				
				r+=v[group[n][k]*6+3];
				g+=v[group[n][k]*6+4];
				b+=v[group[n][k]*6+5];
			
			}
			
			r/=group[n].size();
			g/=group[n].size();
			b/=group[n].size();
			
			std::vector<int> *tmp = &indices[n];
			for(int k=0; k<tmp->size(); k++) {
				v[indices[n][k]*6+3] = r;
				v[indices[n][k]*6+4] = g;
				v[indices[n][k]*6+5] = b;
			}
		}
		
		NSMutableString *obj = [NSMutableString stringWithString:@""];
		
		for(int n=0; n<length; n++) {
			[obj appendString:[NSString stringWithFormat:@"v %0.4f %0.4f %04f %0.4f %0.4f %0.4f\n",v[n*6+0],v[n*6+1],v[n*6+2],v[n*6+3],v[n*6+4],v[n*6+5]]];
		} 
		
		for(int n=0; n<length/6; n++) {
			[obj appendString:[NSString stringWithFormat:@"f %d %d %d\n",1+n*6+0,1+n*6+1,1+n*6+2]];
			[obj appendString:[NSString stringWithFormat:@"f %d %d %d\n",1+n*6+3,1+n*6+4,1+n*6+5]];
		} 
		
		[obj writeToFile:@"blur.obj" atomically:YES encoding:NSUTF8StringEncoding error:nil];
	}
}